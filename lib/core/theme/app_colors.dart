import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF1A1B2E);   
  static const Color surface = Color(0xFF252640);       
  static const Color surfaceElevated = Color(0xFF2E2F50);

  // Brand
  static const Color primary = Color(0xFF4CAF70);       
  static const Color primaryDisabled = Color(0xFF2E5A3E);
  static const Color oppositeOfPrimary = Colors.redAccent;
  static const Color oppositeOfPrimaryHover = Colors.redAccent;
  static const Color oppositeOfPrimaryDisabled = Colors.redAccent; // red is already a strong
  static const Color accent = Color(0xFFFF9800);
  static const Color accentHover = Color(0xFFFFA733);
  static const Color accentDisabled = Color(0xFF5A3E2E);


  // Feedback
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF4CAF70);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  static const Color neutral = Color(0xFF6B6F8A);
  static const Color neutralHover = Color(0xFF7B7F9A);
  static const Color neutralDisabled = Color(0xFF3A3C5A);
  

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B3CC);
  static const Color textMuted = Color(0xFF6B6F8A);

  // Input
  static const Color border = Color(0xFF3A3C5A);
  static const Color inputFill = Color(0xFF252640);

  // Status (overview screen)
  static const Color statusGood = Color(0xFF4CAF70);    
  static const Color statusBusy = Color(0xFFFF9800);    
  static const Color statusOverloaded = Color(0xFFE53935); 

  // Energy bar
  static const Color energyHigh = Color(0xFF4CAF70);
  static const Color energyLow = Color(0xFFE53935);

  // progress bar
  static const Color progressStart = Color.fromARGB(255, 89, 94, 203);
  static const Color progressEnd = Color.fromARGB(255, 6, 15, 186);

  // color for survey screen card background coming in
  static const surveyBackground_1 = Color(0xFF28274C);
  static const surveyBackground_2 = Color(0xFF525273);
  static const surveyBackground_3 = Color(0xFF34325E);
  static const surveyBackground_4 = Color(0xFF252351);

}