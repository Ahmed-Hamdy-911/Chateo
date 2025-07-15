import 'package:chateo/views/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({
    super.key,
    required this.messageError,
  });
  final String messageError;

  @override
  Widget build(BuildContext context) {
    return Center(child: CustomText(text: messageError));
  }
}
