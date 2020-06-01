import 'package:flutter/material.dart';

/// Custom Dialog in Flutter
/// https://medium.com/@excogitatr/custom-dialog-in-flutter-d00e0441f1d5
class StressSliderDialog extends StatefulWidget {
  /// Creates a StatelessElement to manage this widget's location in the tree.
  final double min;
  final double max;
  final int divisions;
  final double current;
  final List<double> valuesNotAllowed;
  final String text;

  StressSliderDialog({
    this.min,
    this.max,
    this.divisions,
    this.current,
    this.text,
    this.valuesNotAllowed,
  });

  ///Creates a StatelessElement to manage this widget's location in the tree.
  @override
  _StressSliderDialogState createState() => _StressSliderDialogState();
}

class _StressSliderDialogState extends State<StressSliderDialog> {
  var _feedbackText = "Totalmente indiferente";
  double _sliderValue = 0.0;

  String imageTitle = "assets/images/stress/stress_0.png";

  void _close() {
    Navigator.pop(context, -1.0);
  }

  void _save() {
    Navigator.pop(context, _sliderValue);
  }

  @override
  void initState() {
    _sliderValue = widget.current;
    super.initState();

    onSliderChanged(_sliderValue);
  }

  void onSliderChanged(double newValue) {
    setState(() {
      _sliderValue = newValue;
      if (_sliderValue < 5) {
        imageTitle = "assets/images/stress/stress_0.png";
        _feedbackText = "Totalmente indiferente";
      } else if (_sliderValue < 10.0) {
        imageTitle = "assets/images/stress/stress_1.png";
        _feedbackText = "";
      } else if (_sliderValue >= 10 && _sliderValue < 20) {
        imageTitle = "assets/images/stress/stress_2.png";
        _feedbackText = "";
      } else if (_sliderValue >= 20 && _sliderValue < 30) {
        imageTitle = "assets/images/stress/stress_3.png";
        _feedbackText = "Algo intranquilo";
      } else if (_sliderValue >= 30 && _sliderValue < 40) {
        imageTitle = "assets/images/stress/stress_4.png";
        _feedbackText = "";
      } else if (_sliderValue >= 40 && _sliderValue < 50) {
        imageTitle = "assets/images/stress/stress_5.png";
        _feedbackText = "Intranquilo";
      } else if (_sliderValue >= 50 && _sliderValue < 60) {
        imageTitle = "assets/images/stress/stress_6.png";
        _feedbackText = "";
      } else if (_sliderValue >= 60 && _sliderValue < 70) {
        imageTitle = "assets/images/stress/stress_7.png";
        _feedbackText = "Bastante intranquilo";
      } else if (_sliderValue >= 70 && _sliderValue < 80) {
        imageTitle = "assets/images/stress/stress_8.png";
        _feedbackText = "";
      } else if (_sliderValue >= 80 && _sliderValue < 90) {
        imageTitle = "assets/images/stress/stress_9.png";
        _feedbackText = "Muy intranquilo/a y tenso/a";
      } else if (_sliderValue >= 90 && _sliderValue < 100) {
        imageTitle = "assets/images/stress/stress_10.png";
        _feedbackText = "";
      } else {
        imageTitle = "assets/images/stress/stress_10.png";
        _feedbackText = "Tan ansioso/a que no puedo resistirlo";
      }
    });
  }

  Widget _buildPainSlider(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        16.0,
      ),
      decoration: new BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // To make the card compact
        children: <Widget>[
          Container(
            child: Text(
              widget.text,
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .apply(fontSizeFactor: 0.8),
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(
            height: 30,
          ),
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
          Text("(" + _sliderValue.toStringAsFixed(0) + " USAs)"),
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
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FlatButton(
                onPressed: _close,
                child: Text("Cancelar"),
                color: Colors.white,
                textColor: Colors.grey,
              ),
              SizedBox(
                width: 40,
              ),
              FlatButton(
                onPressed: (widget.valuesNotAllowed != null &&
                        widget.valuesNotAllowed.contains(_sliderValue))
                    ? null
                    : _save,
                textColor: Theme.of(context).primaryColor,
                color: Colors.white,
                child: Text(
                  "Guardar",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: _buildPainSlider(context),
    );
  }
}
