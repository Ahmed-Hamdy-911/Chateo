import 'package:flutter/material.dart';

import '../../constants/constants.dart';

class CustomMaterialButton extends StatelessWidget {
  const CustomMaterialButton({
    super.key,
    this.onPressed,
    this.color = kMainColor,
    // required this.title,
    required this.widget,
  });
  final VoidCallback? onPressed;
  final Color? color;
  // final String title;
  final Widget? widget;
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        onPressed: onPressed,
        color: color,
        minWidth: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.07,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: widget);
  }
}
