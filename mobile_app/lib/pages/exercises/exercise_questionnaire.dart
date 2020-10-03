import 'package:flutter/material.dart';

import '../../models/exercise.dart';
import '../../models/exposure_exercise.dart';
import '../../models/questionnaire_item.dart';
import '../../services/auth.dart';
import '../../services/firestore.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/exercise_completed_popup.dart';
import '../../widgets/progress.dart';
import '../../widgets/stress_slider.dart';
import '../questionnaire/questionnaire_components.dart';
import 'exercise_running.dart';

class ExerciseQuestionnaire extends StatefulWidget {
  final ExerciseQuestionnaireType type;
  final Exercise exercise;

  ExerciseQuestionnaire(this.type, this.exercise);
  _ExerciseQuestionnaireState createState() => _ExerciseQuestionnaireState();
}

class _ExerciseQuestionnaireState extends State<ExerciseQuestionnaire> {
  bool _isLoading = false;

  QuestionnaireItem _currentQuestionnaireItem;
  List<QuestionnaireItem> _items;
  int _currentIndex = 0;

  /// Variables used as controllers for handle changes in questions answers
  String _choiceInputSelected = '';
  List<String> _multipleChoiceInputSelected = [];
  bool _booleanInputSelected;

  /// Create a global key that uniquely identifies the Scaffold widget,
  /// and allows to display snackbars.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _items = widget.type == ExerciseQuestionnaireType.before
        ? beforeQuestions
        : afterQuestions;
    _currentQuestionnaireItem = _items[_currentIndex];
    super.initState();
  }

  @override
  void dispose() {
    if (widget.type == ExerciseQuestionnaireType.before) {
      beforeQuestions.forEach(
        (element) {
          element.answerValue = null;
        },
      );
    } else {
      afterQuestions.forEach(
        (element) {
          element.answerValue = null;
        },
      );
    }
    super.dispose();
  }

  Future<void> _onCompleted() async {
    setState(() {
      _isLoading = true;
    });
    if (widget.type == ExerciseQuestionnaireType.before) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseRunningPage(widget.exercise),
          ));

      widget.exercise.currentExposure.usasBefore = _items[0].answerValue;
      widget.exercise.currentExposure.panicBefore = _items[1].answerValue ?? [];
      widget.exercise.currentExposure.selfEfficacyBefore =
          _items[2].answerValue;
    } else {
      // Cuestionario después de la exp. completado
      ExposureExercise exposure = widget.exercise.currentExposure;
      exposure.usasAfter = _items[1].answerValue;
      exposure.panicAfter = _items[0].answerValue ?? [];

      setState(() {
        _isLoading = true;
      });
      bool completed = await evaluateCompleted(exposure);
      await createExposureExercise(exposure);
      widget.exercise.currentExposure = null;
      widget.exercise.exposures.add(exposure);

      Navigator.pop(context);
      // Pop to exercises page
      Navigator.pop(context);
      if (completed) {
        showDialog(
          context: context,
          builder: (context) => ExerciseCompletedDialog(widget.exercise),
        );
      }
    }
  }

  Future<bool> evaluateCompleted(ExposureExercise exposure) async {
    if (widget.exercise.status == ExerciseStatus.completed) {
      widget.exercise.afterCompleteAttempts--;
      await updateExercise(widget.exercise.id,
          {'afterCompleteAttempts': widget.exercise.afterCompleteAttempts});
      return false;
    }
    bool anxietyCompleted = false;
    if (widget.exercise.originalUsas > 25) {
      anxietyCompleted = exposure.usasAfter <= 25;
    } else {
      anxietyCompleted = exposure.usasAfter == 0 ||
          exposure.usasAfter <= widget.exercise.originalUsas - 10;
    }
    if (exposure.selfEfficacyBefore >= 75 && anxietyCompleted) {
      AuthService().user.patient.getExercise(widget.exercise.id).status =
          ExerciseStatus.completed;
      exposure.completedExercise = true;
      await updateExerciseStatus(widget.exercise.id, ExerciseStatus.completed);
      if (widget.exercise.index <
          AuthService().user.patient.exercises.length - 1) {
        Exercise newExercise =
            AuthService().user.patient.exercises[widget.exercise.index + 1];
        newExercise.status = ExerciseStatus.in_progress;
        await updateExerciseStatus(newExercise.id, ExerciseStatus.in_progress);
      }
      return true;
    }
    return false;
  }

  Future<void> _onContinue() async {
    int index = _currentIndex + 1;

    // Reset input controller for this questionnaire item
    _booleanInputSelected = null;
    _choiceInputSelected = '';
    _multipleChoiceInputSelected = [];

    // Not all questions have been completed
    if (index < _items.length) {
      setState(() {
        _currentIndex = index;
        _currentQuestionnaireItem = _items[index];
      });
    }

    // End of questionnaire
    else {
      await _onCompleted();
    }
  }

  /// Method used to used handle the system back button.
  /// Return true if the route to be popped
  Future<bool> _willPopCallback() async {
    bool close = false;
    await showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: "¿Seguro que quieres salir?",
        description: "No se guardará nada sobre la exposición actual",
        buttonText2: "Salir",
        buttonFunction2: () {
          close = true;
          widget.exercise.currentExposure = null;
          Navigator.pop(context);
        },
        buttonFunction1: () {
          close = false;
          Navigator.pop(context);
        },
        buttonText1: "Cancelar",
      ),
    );
    return close;
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _currentQuestionnaireItem = _items[_currentIndex];
      });
    }
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

    if (index >= 0) {
      _selectedValues.removeAt(index);
    } else {
      _selectedValues.add(value);
    }

    setState(() {
      _multipleChoiceInputSelected = _selectedValues;
      if (_selectedValues.length > 0) {
        _currentQuestionnaireItem.answerValue = _selectedValues;
      } else {
        _currentQuestionnaireItem.answerValue = null;
      }
    });
  }

  void _onSliderInput(double value) {
    setState(() {
      _currentQuestionnaireItem.answerValue = value.toInt();
    });
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
    switch (_currentQuestionnaireItem.type) {
      case QuestionnaireItemType.choice:
        if (_currentQuestionnaireItem.answerValue != null) {
          _choiceInputSelected = _currentQuestionnaireItem.answerValue;
        }
        input = choiceInput(context, _currentQuestionnaireItem.answerValueSet,
            _choiceInputSelected, _onChoiceInputTap);
        break;

      case QuestionnaireItemType.multiple_choice:
        if (_currentQuestionnaireItem.answerValue != null) {
          _multipleChoiceInputSelected = _currentQuestionnaireItem.answerValue;
        }

        input = multipleChoiceInput(
            context,
            _currentQuestionnaireItem.answerValueSet,
            _multipleChoiceInputSelected,
            _onMultipleChoiceInputTap);
        break;

      case QuestionnaireItemType.boolean:
        _booleanInputSelected = _currentQuestionnaireItem.answerValue;
        input = booleanInput(context, _onBooleanInputTap,
            selectedValue: _booleanInputSelected);
        break;

      case QuestionnaireItemType.slider:
        input = Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: StressSlider(
              max: 100,
              valuesNotAllowed: [0, 100],
              current: 0,
              onUpdate: _onSliderInput,
              isAnxiety: widget.type == ExerciseQuestionnaireType.before &&
                      _currentIndex == 0 ||
                  widget.type == ExerciseQuestionnaireType.after &&
                      _currentIndex == 1,
              isSelfEvaluate: widget.type == ExerciseQuestionnaireType.before &&
                  _currentIndex == 2),
        );
        break;

      default:
        input = Text(
          _currentQuestionnaireItem.type.toString(),
        );
    }

    return input;
  }

  Widget _buildPage(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.1,
          vertical: MediaQuery.of(context).size.height * 0.03,
        ),
        children: <Widget>[
          questionnaireStepper(context, MediaQuery.of(context).size.width * 0.8,
              _items.length, _currentIndex,
              backArrowVisible: _currentIndex > 0, onBack: _previousQuestion),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Text(
            "Cuestionario de autoeficacia",
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
            textAlign: TextAlign.justify,
          ),
          _buildQuestionInfo(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          _buildQuestionInput(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool continueButtonEnabled = _currentQuestionnaireItem != null
        ? (!_currentQuestionnaireItem.mandatory ||
            _currentQuestionnaireItem.answerValue != null)
        : false;
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        key: _scaffoldKey,
        body: _isLoading ? circularProgress(context) : _buildPage(context),
        bottomNavigationBar: !_isLoading
            ? continueButton(context, () async {
                _onContinue();
              }, enabled: continueButtonEnabled)
            : null,
      ),
    );
  }
}

enum ExerciseQuestionnaireType { before, after }

// List of questions before exercise
List<QuestionnaireItem> beforeQuestions = [
  QuestionnaireItem(
      text: """En una escala de 0 a 100 (siendo 0 "nada de ansiedad" y 100 
          "un gran nivel de ansiedad"), ¿qué ansiedad te provoca la situación 
          a la que te vas a exponer? """,
      mandatory: true,
      type: QuestionnaireItemType.slider,
      id: "usasBefore"),
  QuestionnaireItem(
      text:
          """Durante el ejercicio de exposición, ¿crees que ocurrirá alguna de 
          las siguientes situaciones?""",
      mandatory: false,
      type: QuestionnaireItemType.multiple_choice,
      answerValueSet: [
        AnswerValue(
            value: "ataque_ansiedad", text: "Tener un ataque de ansiedad"),
        AnswerValue(
            value: "bloqueo", text: "Bloquearme y no saber cómo reaccionar"),
        AnswerValue(
            value: "ataque_corazon", text: "Tener un ataque al corazón"),
        AnswerValue(value: "desmayo", text: "Desmayarme"),
        AnswerValue(
            value: "ridiculo", text: "Llamar la atención o hacer el ridículo"),
        AnswerValue(
            value: "perder_control", text: "Perder el control del vehículo"),
        AnswerValue(value: "embarazosa", text: "Será una situación embarazosa"),
      ],
      id: "panicBefore"),
  QuestionnaireItem(
      text:
          """En una escala de 0 a 100, dónde 0 equivale a "no puedo hacerlo” y 
          100 “me considero totalmente seguro de poder hacerlo”, evalúa cómo de 
          seguro estás de poder completar el ejercicio.""",
      mandatory: true,
      type: QuestionnaireItemType.slider,
      id: "selfBefore"),
];
List<QuestionnaireItem> afterQuestions = [
  QuestionnaireItem(
      text: """Indica si durante el ejercicio de exposición has experimentado 
          alguna de las siguientes sensaciones.""",
      mandatory: false,
      type: QuestionnaireItemType.multiple_choice,
      answerValueSet: [
        AnswerValue(
            value: "ataque_corazon",
            text: "Latidos rápidos o fuertes del corazón"),
        AnswerValue(value: "sudor", text: "Sudores"),
        AnswerValue(value: "falta_aire", text: "Falta de aire"),
        AnswerValue(value: "escalofrio", text: "Escalofríos"),
        AnswerValue(value: "mareo", text: "Vértigos, mareos, inestabilidad"),
        AnswerValue(
            value: "perder_control",
            text: "Miedo a perder el control del vehículo"),
        AnswerValue(value: "pecho", text: "Dolor o malestar en el pecho"),
        AnswerValue(
            value: "estomago", text: "Vómitos o malestar en el estómago"),
      ],
      id: "panicAfter"),
  QuestionnaireItem(
      text: """En una escala de 0 a 100 (siendo 0 "nada de ansiedad" y 100 
          "un gran nivel de ansiedad") ¿qué nivel de ansiedad consideras que 
          te ha provocado la situación una vez que te has expuesto a ella?""",
      mandatory: true,
      type: QuestionnaireItemType.slider,
      id: "usasAfter"),
];
