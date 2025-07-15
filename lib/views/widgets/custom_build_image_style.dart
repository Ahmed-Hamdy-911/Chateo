import 'package:flutter/material.dart';
import '../../services/format_services.dart';
import 'custom_text.dart';

class CustomBuildImageStyle extends StatelessWidget {
  const CustomBuildImageStyle({
    super.key,
    this.name,
    this.defaultBackGroundColor = const Color(0xff166FF6),
  });

  final Color? defaultBackGroundColor;
  final String? name;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.105,
      width: size.width * 0.19,
      padding: const EdgeInsets.all(2).copyWith(top: 8, bottom: 8),
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: defaultBackGroundColor),
          child: name != null
              ? Center(
                  child: CustomText(
                  color: Colors.white,
                  text: FormatServices()
                      .returnFirstAndLastInitials(name: name)
                      .toString()
                      .toUpperCase(),
                  fontSize: size.width * 0.04,
                ))
              : null),
    );
  }
}
