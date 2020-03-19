import 'package:flutter/material.dart';
import 'package:tfg_app/themes/custom_icon_icons.dart';

Widget customTextInput(String hint, IconData icon,
    {TextEditingController controller,
    Function(String) validator,
    TextInputType keyboardType = TextInputType.text}) {
  return TextFormField(
    decoration: InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 0),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      prefixIcon: Icon(
        icon,
        size: 20,
      ),
      hintText: hint,
    ),
    // The validator receives the text that the user has entered.
    validator: validator,
    autofocus: false,
    controller: controller,
    keyboardType: keyboardType,
    style: TextStyle(fontSize: 14),
  );
}

Widget customPasswordInput(String hint, IconData icon,
    {TextEditingController controller,
    bool visible = false,
    Function visibleController,
    Function(String) validator,
    Function onChanged}) {
  return TextFormField(
    decoration: InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 0),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      suffixIcon: IconButton(
        icon: Icon(!visible ? CustomIcon.ojo : CustomIcon.esconder),
        onPressed: visibleController,
      ),
      prefixIcon: Icon(
        icon,
        size: 20,
      ),
      hintText: hint,
    ),
    obscureText: !visible,
    // The validator receives the text that the user has entered.
    validator: validator,
    keyboardType: TextInputType.visiblePassword,
    controller: controller,
    onChanged: onChanged,
    autofocus: false,
    style: TextStyle(fontSize: 14),
  );
}
