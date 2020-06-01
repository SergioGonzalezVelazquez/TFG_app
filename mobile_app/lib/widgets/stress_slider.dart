import 'package:flutter/material.dart';

/// Custom Dialog in Flutter
/// https://medium.com/@excogitatr/custom-dialog-in-flutter-d00e0441f1d5
class StressSlider extends StatefulWidget {
  /// Creates a StatelessElement to manage this widget's location in the tree.
  final double min;
  final double max;
  final int divisions;
  final double current;
  final List<double> valuesNotAllowed;
  final Function onUpdate;
  final bool isAnxiety;
  final bool isSelfEvaluate;

  StressSlider(
      {this.min,
      this.max,
      this.divisions,
      this.current,
      this.valuesNotAllowed,
      this.isAnxiety,
      this.isSelfEvaluate,
      this.onUpdate});

  ///Creates a StatelessElement to manage this widget's location in the tree.
  @override
  _StressSliderState createState() => _StressSliderState();
}

class _StressSliderState extends State<StressSlider> {
  var _feedbackText;
  double _sliderValue;

  String imageTitle = "assets/images/stress/stress_0.png";

  void _close() {
    Navigator.pop(context, -1.0);
  }

  void _save() {
    Navigator.pop(context, _sliderValue);
  }

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.current;
    imageTitle = getImage();
    _feedbackText = getText();
  }

  String getImage() {
    if (widget.isSelfEvaluate != null && widget.isSelfEvaluate) {
      return getImageSelfEvaluate();
    } else if (widget.isAnxiety != null && widget.isAnxiety) {
      return getImageAnxiety();
    }
    return "";
  }

  String getImageAnxiety() {
    String image = '';
    if (_sliderValue < 5) {
      image = "assets/images/stress/stress_0.png";
    } else if (_sliderValue < 10.0) {
      image = "assets/images/stress/stress_1.png";
    } else if (_sliderValue >= 10 && _sliderValue < 20) {
      image = "assets/images/stress/stress_2.png";
    } else if (_sliderValue >= 20 && _sliderValue < 30) {
      image = "assets/images/stress/stress_3.png";
    } else if (_sliderValue >= 30 && _sliderValue < 40) {
      image = "assets/images/stress/stress_4.png";
    } else if (_sliderValue >= 40 && _sliderValue < 50) {
      image = "assets/images/stress/stress_5.png";
    } else if (_sliderValue >= 50 && _sliderValue < 60) {
      image = "assets/images/stress/stress_6.png";
    } else if (_sliderValue >= 60 && _sliderValue < 70) {
      image = "assets/images/stress/stress_7.png";
    } else if (_sliderValue >= 70 && _sliderValue < 80) {
      image = "assets/images/stress/stress_8.png";
    } else if (_sliderValue >= 80 && _sliderValue < 90) {
      image = "assets/images/stress/stress_9.png";
    } else if (_sliderValue >= 90 && _sliderValue < 100) {
      image = "assets/images/stress/stress_10.png";
    } else {
      image = "assets/images/stress/stress_10.png";
    }
    return image;
  }

  String getImageSelfEvaluate() {
    String image = '';
    if (_sliderValue < 5) {
      image = "assets/images/stress/self_0.png";
    } else if (_sliderValue < 10.0) {
      image = "assets/images/stress/self_1.png";
    } else if (_sliderValue >= 10 && _sliderValue < 20) {
      image = "assets/images/stress/self_2.png";
    } else if (_sliderValue >= 20 && _sliderValue < 30) {
      image = "assets/images/stress/self_3.png";
    } else if (_sliderValue >= 30 && _sliderValue < 40) {
      image = "assets/images/stress/self_4.png";
    } else if (_sliderValue >= 40 && _sliderValue < 50) {
      image = "assets/images/stress/self_5.png";
    } else if (_sliderValue >= 50 && _sliderValue < 60) {
      image = "assets/images/stress/self_6.png";
    } else if (_sliderValue >= 60 && _sliderValue < 70) {
      image = "assets/images/stress/self_7.png";
    } else if (_sliderValue >= 70 && _sliderValue < 80) {
      image = "assets/images/stress/self_8.png";
    } else if (_sliderValue >= 80 && _sliderValue < 90) {
      image = "assets/images/stress/self_9.png";
    } else if (_sliderValue >= 90 && _sliderValue < 100) {
      image = "assets/images/stress/self_10.png";
    } else {
      image = "assets/images/stress/self_10.png";
    }
    return image;
  }

  String getText() {
    if (widget.isSelfEvaluate != null && widget.isSelfEvaluate) {
      return getTextSelfEvaluate();
    } else if (widget.isAnxiety != null && widget.isAnxiety) {
      return getTextAnxiety();
    }
    return "";
  }

  String getTextAnxiety() {
    String text = '';

    if (_sliderValue == 0) {
      return "Nada de ansiedad";
    } else if (_sliderValue == 25) {
      return "Algo de ansiedad";
    } else if (_sliderValue == 75) {
      return "Bastante ansiedad";
    } else if (_sliderValue == 100) {
      return "Un gran nivel de ansiedad";
    }

    return text;
  }

  String getTextSelfEvaluate() {
    String text = '';

    if (_sliderValue < 5) {
      return "No puedo hacerlo";
    } else if (_sliderValue == 50) {
      return "Relativamente seguro de poder hacerlo";
    } else if (_sliderValue > 95) {
      return "Seguro de poder hacerlo";
    }

    return text;
  }

  void onSliderChanged(double newValue) {
    widget.onUpdate(newValue);
    if (this.mounted) {
      setState(() {
        _sliderValue = newValue;
        _feedbackText = getText();
        imageTitle = getImage();
      });
    }
  }

  Widget _buildPainSlider(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // To make the card compact
      children: <Widget>[
        Image.asset(
          imageTitle,
          height: MediaQuery.of(context).size.height * 0.18,
          fit: BoxFit.contain,
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          _feedbackText,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text((widget.isAnxiety
            ? "(" + _sliderValue.toStringAsFixed(0) + " USAs)"
            : _sliderValue.toStringAsFixed(0))),
        Container(
          child: Slider(
            min: widget.min != null ? widget.min : 0,
            max: widget.max != null ? widget.max : 100,
            divisions: widget.divisions != null ? widget.divisions : 20,
            value: _sliderValue,
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: Colors.grey,
            onChanged: onSliderChanged,
          ),
        ),
        SizedBox(height: 24.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildPainSlider(context);
  }
}
