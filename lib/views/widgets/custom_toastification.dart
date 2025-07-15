import 'package:chateo/views/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showToastification(
  context, {
  required String title,
  required String message,
  ToastificationType? type,
}) {
  toastification.show(
    context: context,
    alignment: Alignment.bottomCenter,
    applyBlurEffect: true,
    title: CustomText(
      text: title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      color: returnCustomBGToastification(type!),
    ),
    description: CustomText(
      text: message,
      maxLines: 5,
      color: Colors.black,
    ),
    type: type,
    icon: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: returnCustomBGToastification(type),
        ),
      ),
      child: Icon(
        returnCustomIconToastification(type),
      ),
    ),
    style: ToastificationStyle.flat,
    autoCloseDuration: const Duration(seconds: 5),
  );
}

IconData returnCustomIconToastification(ToastificationType type) {
  IconData? iconData;
  switch (type) {
    case ToastificationType.success:
      iconData = Icons.done;
      break;
    case ToastificationType.error:
      iconData = Icons.close;
      break;
    case ToastificationType.warning:
      iconData = Icons.warning_amber_rounded;
      break;
    default:
      iconData = Icons.info;
  }
  return iconData;
}

Color returnCustomBGToastification(ToastificationType type) {
  Color? color;
  switch (type) {
    case ToastificationType.success:
      color = Colors.green;
      break;
    case ToastificationType.error:
      color = Colors.red;
      break;
    case ToastificationType.warning:
      color = Colors.yellow;
      break;
    default:
      color = Colors.blue;
  }
  return color;
}
