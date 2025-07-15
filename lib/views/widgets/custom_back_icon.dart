import 'package:flutter/material.dart';

class CustomBackIcon extends StatelessWidget {
  const CustomBackIcon({
    super.key,
    this.onPressed,
  });
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed ??
          () {
            Navigator.pop(context);
          },
      icon: const Icon(
        Icons.arrow_back_ios,
        size: 22,
        color: Colors.black,
      ),
    );
  }
}
