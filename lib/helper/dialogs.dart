import 'package:flutter/material.dart';
class Dialogs
{
  static void showSnackbar(BuildContext  context, String msg)
  {
   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    behavior: SnackBarBehavior.floating,
    content:Text(msg),
    backgroundColor: Colors.red.withOpacity(1),));
  }

  static void showProgressBar(BuildContext context)
  {
    showDialog(context: context, builder: (_) => Center(child: CircularProgressIndicator()));
  }
}