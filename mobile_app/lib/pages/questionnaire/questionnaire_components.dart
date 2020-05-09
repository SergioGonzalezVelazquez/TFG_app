import 'package:flutter/material.dart';
import 'package:tfg_app/models/questionnaire_item.dart';

Widget questionnaireStepper(
    BuildContext context, double screenWidth, int size, int currentIndex,
    {double height = 10, bool backArrowVisible = false, Function onBack}) {
  double marginBetween = 7;
  double backIconSize = 22;
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      size + 1,
      (int index) {
        return index == 0
            ? Visibility(
                visible: backArrowVisible,
                child: InkWell(
                  child: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).primaryColor,
                    size: backIconSize,
                  ),
                  onTap: backArrowVisible ? onBack : null,
                ),
              )
            : Container(
                padding: EdgeInsets.only(),
                decoration: BoxDecoration(
                  color: index <= currentIndex + 1
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(2.0)),
                ),
                height: 10.0,
                width: (screenWidth -
                        (marginBetween * (size - 1)) -
                        (backArrowVisible ? marginBetween * 2 : 0) -
                        (backArrowVisible ? backIconSize : 0)) /
                    size,
                margin: EdgeInsets.only(
                    left:
                        index == 1 && backArrowVisible ? marginBetween * 2 : 0,
                    right: index == size ? 0 : marginBetween),
              );
      },
    ),
  );
}

BottomAppBar continueButton(
    BuildContext context, bool enabled, void Function() onTap) {
  return BottomAppBar(
    child: Opacity(
      opacity: enabled ? 1 : 0,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorLight.withAlpha(100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(200),
            ),
          ],
        ),
        height: MediaQuery.of(context).size.height * 0.08,
        child: InkWell(
          child: Center(
            child: Text(
              "Continuar",
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 16),
            ),
          ),
          onTap: enabled ? onTap : null,
        ),
      ),
    ),
  );
}

Widget choiceInput(BuildContext context, List<AnswerValue> answerValueSet,
    String selectedValue, Function onRadioTap) {
  return Center(
    child: Container(
      child: Card(
        child: Column(
          children: List.generate(answerValueSet.length, (int index) {
            final answerValue = answerValueSet[index];
            return GestureDetector(
              onTapUp: (detail) {
                onRadioTap(answerValue.value);
              },
              child: Container(
                color: selectedValue == answerValue.value
                    ? Theme.of(context).primaryColorLight.withAlpha(100)
                    : Colors.white,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Radio(
                          activeColor: Theme.of(context).primaryColorDark,
                          value: answerValue.value,
                          groupValue: selectedValue,
                          onChanged: (String value) {
                            onRadioTap(value);
                          },
                        ),
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(right: 15, top: 5, bottom: 10),
                            child: Text(
                              answerValue.text,
                              style: TextStyle(
                                  fontWeight: selectedValue == answerValue.value
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                            ),
                          ),
                        )
                      ],
                    ),
                    Divider(
                      height: index < answerValueSet.length ? 1.0 : 0.0,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    ),
  );
}

Widget multipleChoiceInput(
    BuildContext context,
    List<AnswerValue> answerValueSet,
    List<String> selectedValues,
    Function onChoiceTap) {
  return Center(
    child: Container(
      child: Card(
        child: Column(
          children: List.generate(
            answerValueSet.length,
            (int index) {
              final answerValue = answerValueSet[index];
              bool selected = selectedValues.contains(answerValue.value);
              return Column(
                children: <Widget>[
                  GestureDetector(
                    onTapUp: (detail) {
                      onChoiceTap(answerValue.value);
                    },
                    child: Container(
                      color: selected
                          ? Theme.of(context).primaryColorLight.withAlpha(100)
                          : Colors.white,
                      child: Row(
                        children: <Widget>[
                          Checkbox(
                            activeColor: Theme.of(context).primaryColorDark,
                            value: selected,
                            onChanged: (bool value) {
                              onChoiceTap(answerValue.value);
                            },
                          ),
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                answerValue.text,
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.normal),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: index < answerValueSet.length ? 1.0 : 0.0,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}

Widget booleanInput(
    BuildContext context, bool selectedValue, Function onRadioTap) {
  return Center(
    child: Container(
      child: Card(
        child: Column(
          children: List.generate(2, (int index) {
            final bool radioOption = index == 0;
            return GestureDetector(
              onTapUp: (detail) {
                onRadioTap(radioOption);
              },
              child: Container(
                height: 50.0,
                color: selectedValue == radioOption
                    ? Theme.of(context).primaryColorLight.withAlpha(100)
                    : Colors.white,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Radio(
                          activeColor: Theme.of(context).primaryColorDark,
                          value: radioOption,
                          groupValue: selectedValue,
                          onChanged: (bool value) {
                            onRadioTap(value);
                          },
                        ),
                        Text(
                          radioOption ? 'Sí' : 'No',
                          style: TextStyle(
                              fontWeight: selectedValue == radioOption
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                        )
                      ],
                    ),
                    Divider(
                      height: index == 0 ? 1.0 : 0.0,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    ),
  );
}
