import 'package:flutter/material.dart';

Widget myTextField(String hintText,keyBoardType,controller){
  return TextField(
    style: TextStyle(color: Colors.white),
    keyboardType: keyBoardType,
    controller: controller,
    decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white38,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white54)),
  );
}