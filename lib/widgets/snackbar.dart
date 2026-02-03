import 'package:flutter/material.dart';
import 'package:lendo/config/app_config.dart';

class CustomSnackBar {
  static void show(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.secondary : AppColors.primary,
      ),
    );
  }
}