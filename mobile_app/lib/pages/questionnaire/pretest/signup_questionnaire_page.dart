import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tfg_app/models/patient.dart';
import 'package:tfg_app/models/questionnaire_group.dart';
import 'package:tfg_app/models/questionnaire_item.dart';
import 'package:tfg_app/pages/questionnaire/questionnaire_initial_page.dart';
import 'package:tfg_app/pages/questionnaire/pretest/signup_questionnaire_completed_page.dart';
import 'package:tfg_app/pages/questionnaire/questionnaire_components.dart';
import 'package:tfg_app/services/auth.dart';
import 'package:tfg_app/services/firestore.dart';
import 'package:tfg_app/widgets/progress.dart';
import 'package:tfg_app/widgets/custom_dialog.dart';
import 'package:tfg_app/utils/questionnaire_utils.dart';

class SignUpQuestionnairePage extends StatefulWidget {
  /// Name use for navigate to this screen
  static const route = "/signUpQuestionnaire";

  // Flag used to determine wheter user has a questionnaire
  // in progress or not
  bool inProgress;

  SignUpQuestionnairePage({bool inProgress = false}) {
    this.inProgress = inProgress;
  }

  ///Creates a StatelessElement to manage this widget's location in the tree.
  _SignUpQuestionnairePageState createState() =>
      _SignUpQuestionnairePageState();
}

/// State object for LoginPage that contains fields that affect
/// how it looks.
class _SignUpQuestionnairePageState extends State<SignUpQuestionnairePage>
    with TickerProviderStateMixin {
  /// Controller for animations.
  AnimationController _animateController;

  /// Flags to render loading spinner UI.
  bool _isLoading = true;

  /// List of Questions within the Questionnaire
  List<QuestionnaireItemGroup> _questionsGroups = [];

  /// List of sections within the Questionnaire
  List<QuestionnaireItem> _questionnaireItems = [];

  Map _mapItemToGroup = new Map();

  int _currentGroupIndex = 0;

  /// Question which is being answered
  QuestionnaireItem _currentQuestionnaireItem;

  /// Variables used as controllers for handle changes in questions answers
  String _choiceInputSelected = '';
  List<String> _multipleChoiceInputSelected = [];
  bool _booleanInputSelected;

  bool _inProgress = false;

  AuthService _authService;

  DateTime _lastResponseDate = DateTime.now();

  /// Create a global key that uniquely identifies the Scaffold widget,
  /// and allows to display snackbars.
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  /// Method called when this widget is inserted into the tree.
  /// Initialize animation controller and fecht questionnaire items
  @override
  void initState() {
    _authService = AuthService();
    _animateController = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);
    _loadSignupQuestionnaire();
    super.initState();
  }

  /// Release the resources used by the animation controller
  /// when the widget is removed from the widget tree.
  @override
  void dispose() {
    _animateController.dispose();
    super.dispose();
  }

  /**
  * Functions used to handle events in this screen 
  */

  /// Read questions and sections from Firebase
  Future<void> _loadSignupQuestionnaire() async {
    await getSignupQuestionnaire().then((response) {
      setState(
        () {
          _questionsGroups = response;
          if (response.length > 0)
            _currentQuestionnaireItem = _questionsGroups[0].items[0];
          for (QuestionnaireItemGroup group in _questionsGroups) {
            _questionnaireItems = _questionnaireItems + group.items;
            for (QuestionnaireItem item in group.items) {
              _mapItemToGroup[item.linkId] = group.index;
            }
          }
        },
      );
    });

    if (widget.inProgress) {
      await _setQuestionnaireResponses();
    }

    setState(() {
      _isLoading = false;
    });

    print("inProgress " + _inProgress.toString());
  }

  Future<void> _setQuestionnaireResponses() async {
    Map<String, dynamic> response = await getQuestionnaireResponses();

    if (response == null || response.length <= 1) {
      setState(() {
        _inProgress = false;
      });
    } else {
      int index = 0;

      while (index < _questionnaireItems.length && response.length > 1) {
        QuestionnaireItem item = _questionnaireItems[index];
        if (response.containsKey(item.id)) {
          _questionnaireItems[index].answerValue = response[item.id];
          response.removeWhere((key, value) => key == item.id);
        }
        index++;
      }
      index--;
      setState(() {
        _inProgress = (index > 0);
        if (_inProgress) {
          _lastResponseDate = response['start_at'].toDate();
          _currentQuestionnaireItem = _questionnaireItems[index - 1];
          print(_currentQuestionnaireItem.linkId.toString());
          _currentGroupIndex =
              _mapItemToGroup[_currentQuestionnaireItem.linkId];

          print(_currentGroupIndex);
        }
      });
    }
  }

  Future _startAnimation() async {
    try {
      await _animateController.forward().orCancel;
      setState(() {});
    } on TickerCanceled {}
  }

  /// Method used to used handle the system back button.
  Future<bool> _onWillPop() async {
    bool close = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        title: "¿Seguro que quieres salir?",
        description:
            "Cuando vuelvas podrás continuar respondiendo desde la última pregunta en que lo dejaste.",
        buttonText2: "Salir",
        buttonFunction2: () {
          close = true;
          Navigator.pop(context);
        },
        buttonFunction1: () {
          close = false;
          Navigator.pop(context);
        },
        buttonText1: "Continuar",
      ),
    );
    return close;
  }

  void _continue() {
    addSignUpResponse(_currentQuestionnaireItem);

    // If answer has been updated, check enableWhen clauses of
    // other questions which depends on this current question
    if (_currentQuestionnaireItem.updated) {
      evaluateAndDeleteAnswers(_currentQuestionnaireItem, _questionnaireItems);
    }

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
              .bodyText1
              .apply(color: Theme.of(context).primaryColor),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.03,
        ),
        Text(
          _currentQuestionnaireItem.text,
          style: Theme.of(context).textTheme.headline6,
        ),
        _buildQuestionInfo(),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        _buildQuestionInput(),
      ],
    );
  }

  Widget _buildQuestionInfo() {
    String mandatory = (_currentQuestionnaireItem.mandatory)
        ? ''
        : 'La respuesta a esta pregunta es opcional.';

    String type = '';
    if (_currentQuestionnaireItem.type ==
        QuestionnaireItemType.multiple_choice) {
      type = !(_currentQuestionnaireItem.mandatory)
          ? 'Si la respondes, puedes seleccionar una o varias respuestas'
          : 'Puedes seleccionar una o varias respuestas';
    } else if (_currentQuestionnaireItem.mandatory) {
      type = 'Elige una única respuesta.';
    }

    return Visibility(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Text(
            mandatory + (mandatory.isNotEmpty ? ' ' : '') + type,
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .apply(fontSizeFactor: 0.8),
          ),
        ],
      ),
      visible: mandatory.isNotEmpty || type.isNotEmpty,
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

  Widget _resumePage() {
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
          height: MediaQuery.of(context).size.height * 0.05,
        ),
        Image.asset(
          'assets/images/4824.jpg',
          width: MediaQuery.of(context).size.width,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
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
          "Empezaste a responder este cuestionario el " +
              _lastResponseDate.toString(),
          textAlign: TextAlign.justify,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Text(
          "Puedes continuar respondiendo por la pregunta en que lo dejaste, o borrar tus respuestas anteriores y empezar a responder desde cero.",
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
                      : (_inProgress
                          ? QuestionnaireInitialPage(
                              buttonText: "Reanudar",
                              animateController: _animateController,
                              pageWidget: _resumePage(),
                              screenWidth: width,
                              screenHeigth: height,
                              onStartAnimation: () {
                                _startAnimation();
                              },
                            )
                          : QuestionnaireInitialPage(
                              buttonText: "Empezar",
                              animateController: _animateController,
                              pageWidget: _welcomePage(),
                              screenWidth: width,
                              screenHeigth: height,
                              onStartAnimation: () {
                                createSignUpResponse();
                                _authService.updatePatientStatus(
                                    PatientStatus.pretest_in_progress);

                                _startAnimation();
                              },
                            )),
                ),
              ),
        bottomNavigationBar: _animateController.isCompleted && !_isLoading
            ? continueButton(context, continueButtonEnabled ?? false, _continue)
            : null,
      ),
    );
  }
}
