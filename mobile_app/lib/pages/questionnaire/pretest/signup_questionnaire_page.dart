import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tfg_app/models/questionnaire_group.dart';
import 'package:tfg_app/models/questionnaire_item.dart';
import 'package:tfg_app/pages/questionnaire/questionnaire_initial_page.dart';
import 'package:tfg_app/pages/questionnaire/pretest/signup_questionnaire_completed_page.dart';
import 'package:tfg_app/pages/questionnaire/questionnaire_components.dart';
import 'package:tfg_app/services/firestore.dart';
import 'package:tfg_app/widgets/progress.dart';
import 'package:tfg_app/utils/questionnaire_utils.dart';

class SignUpQuestionnairePage extends StatefulWidget {
  /// Name use for navigate to this screen
  static const route = "/signUpQuestionnaire";

  ///Creates a StatelessElement to manage this widget's location in the tree.
  _SignUpQuestionnairePageState createState() =>
      _SignUpQuestionnairePageState();
}

class _SignUpQuestionnairePageState extends State<SignUpQuestionnairePage>
    with TickerProviderStateMixin {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  //
  AnimationController _animateController;

  bool _isLoading = true;

  List<QuestionnaireItemGroup> _questionsGroups = [];
  List<QuestionnaireItem> _questionnaireItems = [];
  Map _mapItemToGroup = new Map();
  int _currentGroupIndex = 0;
  QuestionnaireItem _currentQuestionnaireItem;

  String _choiceInputSelected = '';
  List<String> _multipleChoiceInputSelected = [];
  bool _booleanInputSelected;

  // Create a global key that uniquely identifies the Scaffold widget,
  // and allows to display snackbars.
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _animateController = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);
    _loadSignupQuestionnaire();
    super.initState();
  }

  @override
  void dispose() {
    _animateController.dispose();
    super.dispose();
  }

  Future<void> _loadSignupQuestionnaire() async {
    await getSignupQuestionnaire().then((response) {
      setState(() {
        _questionsGroups = response;
        if (response.length > 0)
          _currentQuestionnaireItem = _questionsGroups[0].items[0];
        for (QuestionnaireItemGroup group in _questionsGroups) {
          _questionnaireItems = _questionnaireItems + group.items;
          for (QuestionnaireItem item in group.items) {
            _mapItemToGroup[item.linkId] = group.index;
          }
        }
        _isLoading = false;
      });
    }).catchError((error) {
      print(error);
    });
  }

  /**
  * Functions used to handle events in this screen 
  */
  Future _startAnimation() async {
    try {
      await _animateController.forward().orCancel;
      setState(() {});
    } on TickerCanceled {}
  }

  Future<bool> _onWillPop() async {
    if (_currentQuestionnaireItem != null && _previousQuestion() >= 0) {
      return false;
    }
    //TODO: Mostrar diálogo preguntado si se quiere salir del cuestionario
    return false;
  }

  void _continue() {
    addSignUpResponse(_currentQuestionnaireItem);
    int index = getNextEnableQuestion(
        _questionnaireItems, _currentQuestionnaireItem.linkId - 1);
    // Not all questions have been completed
    if (index > 0) {
      int groupIndex = _mapItemToGroup[index];
      setState(() {
        _currentQuestionnaireItem = _questionnaireItems[index - 1];
        _currentGroupIndex = groupIndex - 1;
      });
    }
    // End of questionnaire
    else {
      Navigator.pushReplacementNamed(
        context,
       SignUpQuestionnaireCompleted.route,
      );
    }
  }

  int _previousQuestion() {
    int index = getPreviousEnableQuestion(
        _questionnaireItems, _currentQuestionnaireItem.linkId - 1);

    if (index > 0) {
      int groupIndex = _mapItemToGroup[index];
      setState(() {
        _currentQuestionnaireItem = _questionnaireItems[index - 1];
        _currentGroupIndex = groupIndex - 1;
      });
    }
    return index;
  }

  void _onChoiceInputTap(String value) {
    if (value == _choiceInputSelected) {
      setState(() {
        _choiceInputSelected = '';
        _currentQuestionnaireItem.answerValue = null;
      });
    } else {
      setState(() {
        _choiceInputSelected = value;
        _currentQuestionnaireItem.answerValue = value;
      });
    }
  }

  void _onBooleanInputTap(bool value) {
    if (value == _booleanInputSelected) {
      setState(() {
        _booleanInputSelected = null;
        _currentQuestionnaireItem.answerValue = null;
      });
    } else {
      setState(() {
        _booleanInputSelected = value;
        _currentQuestionnaireItem.answerValue = value;
      });
    }
  }

  void _onMultipleChoiceInputTap(String value) {
    List<String> _selectedValues = _multipleChoiceInputSelected;
    int index = _selectedValues.lastIndexOf(value);

    if (index >= 0)
      _selectedValues.removeAt(index);
    else
      _selectedValues.add(value);

    setState(() {
      _multipleChoiceInputSelected = _selectedValues;
      if (_selectedValues.length > 0)
        _currentQuestionnaireItem.answerValue = _selectedValues;
      else
        _currentQuestionnaireItem.answerValue = null;
    });
  }

  /**
  * Widgets (ui components) used in this screen 
  */
  Widget _buildPage(BuildContext context) {
    QuestionnaireItemGroup currentGroup = _questionsGroups[_currentGroupIndex];
    return ListView(
      children: <Widget>[
        questionnaireStepper(context, MediaQuery.of(context).size.width * 0.8,
            _questionsGroups.length, _currentGroupIndex,
            backArrowVisible: _currentQuestionnaireItem.linkId > 1,
            onBack: _previousQuestion),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Text(
          currentGroup.name,
          style: Theme.of(context)
              .textTheme
              .headline6
              .apply(color: Theme.of(context).primaryColor),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
        Text(
          _currentQuestionnaireItem.text,
          style: Theme.of(context).textTheme.headline5,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        _buildQuestionInput(),
      ],
    );
  }

  Widget _buildQuestionInput() {
    Widget input;

    // Reset input controller for this questionnaire item
    _booleanInputSelected = null;
    _choiceInputSelected = '';
    _multipleChoiceInputSelected = [];

    switch (_currentQuestionnaireItem.type) {
      case QuestionnaireItemType.choice:
        if (_currentQuestionnaireItem.answerValue != null)
          _choiceInputSelected = _currentQuestionnaireItem.answerValue;
        input = choiceInput(context, _currentQuestionnaireItem.answerValueSet,
            _choiceInputSelected, _onChoiceInputTap);
        break;

      case QuestionnaireItemType.multiple_choice:
        if (_currentQuestionnaireItem.answerValue != null)
          _multipleChoiceInputSelected = _currentQuestionnaireItem.answerValue;

        input = multipleChoiceInput(
            context,
            _currentQuestionnaireItem.answerValueSet,
            _multipleChoiceInputSelected,
            _onMultipleChoiceInputTap);
        break;

      case QuestionnaireItemType.boolean:
        _booleanInputSelected = _currentQuestionnaireItem.answerValue;
        input =
            booleanInput(context, _booleanInputSelected, _onBooleanInputTap);
        break;

      default:
        input = Text(
          _currentQuestionnaireItem.type.toString(),
        );
    }

    return input;
  }

  Widget _welcomePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.1,
        ),
        Text(
          "¡Bienvenido a STOPMiedo!",
          textAlign: TextAlign.justify,
          style: Theme.of(context).textTheme.headline5,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.07,
        ),
        Image.asset(
          'assets/images/4824.jpg',
          width: MediaQuery.of(context).size.width,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.07,
        ),
        Text(
          "Cuéntanos un poco más sobre ti",
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.subtitle1,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Text(
          "Necesitamos conocerte mejor para completar tu perfil y poder encontrar la terapia más apropiada.",
          textAlign: TextAlign.justify,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Text(
          "Tardarás menos de 10 minutos en responder a todas las preguntas",
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool continueButtonEnabled = _currentQuestionnaireItem != null
        ? (!_currentQuestionnaireItem.mandatory ||
            _currentQuestionnaireItem.answerValue != null)
        : false;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        //backgroundColor:  Color(0xffe8eaf6),
        key: _scaffoldKey,
        body: _isLoading
            ? circularProgress(context)
            : Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.1,
                    vertical: height * 0.03,
                  ),
                  child: _animateController.isCompleted
                      ? _buildPage(context)
                      : QuestionnaireInitialPage(
                          buttonText: "Empezar",
                          animateController: _animateController,
                          pageWidget: _welcomePage(),
                          screenWidth: width,
                          screenHeigth: height,
                          onStartAnimation: () {
                            createSignUpResponse();
                            _startAnimation();
                          },
                        ),
                ),
              ),
        bottomNavigationBar: _animateController.isCompleted && !_isLoading
            ? continueButton(context, continueButtonEnabled ?? false, _continue)
            : null,
      ),
    );
  }
}
