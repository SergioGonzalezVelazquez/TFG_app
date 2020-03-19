import 'package:flutter/material.dart';
import 'package:tfg_app/themes/custom_icon_icons.dart';

Widget customTextInput(String hint, IconData icon,
    {TextEditingController controller,
    TextInputType keyboardType = TextInputType.text}) {
  return TextField(
    decoration: InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 0),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      prefixIcon: Icon(
        icon,
        size: 20,
      ),
      hintText: hint,
    ),
    autofocus: false,
    controller: controller,
    keyboardType: keyboardType,
    style: TextStyle(fontSize: 14),
  );
}

Widget customPasswordInput(String hint, IconData icon,
    {TextEditingController controller, bool visible = false}) {
  return TextField(
    decoration: InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 0),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      prefixIcon: Icon(
        icon,
        size: 20,
      ),
      hintText: hint,
    ),
    obscureText: !visible,
    keyboardType: TextInputType.visiblePassword,
    controller: controller,
    autofocus: false,
    style: TextStyle(fontSize: 14),
  );
}
