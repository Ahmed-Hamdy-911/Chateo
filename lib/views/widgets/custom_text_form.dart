import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField(
      {super.key,
      this.validator,
      this.inputFormatters,
      this.keyboardType,
      this.controller,
      this.hintText,
      this.prefixIcon,
      this.suffixIcon,
      this.onChanged,
      this.obscureText = false,
      this.onFieldSubmitted,
      this.prefixText,
      this.enabled = true,
      this.minLines,
      this.maxLines,
      this.contentPadding,
      this.textCapitalization,
      this.onTapOutside});

  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final EdgeInsetsGeometry? contentPadding;
  final String? hintText;
  final String? prefixText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final bool obscureText;
  final bool enabled;
  final int? minLines;
  final int? maxLines;
  final TextCapitalization? textCapitalization;
  final void Function(PointerDownEvent)? onTapOutside;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      controller: controller,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines ?? (minLines ?? 1), // Ensures maxLines >= minLines
      onTapOutside: onTapOutside ??
          (event) {
            FocusScope.of(context).requestFocus(FocusNode());
          },
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        prefixText: prefixText,
        prefixStyle: const TextStyle(color: Color(0xffADB5BD)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            width: 0,
            color: Color(0xffADB5BD),
            style: BorderStyle.none,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        contentPadding: contentPadding ?? const EdgeInsets.all(17),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            width: 0,
            style: BorderStyle.none,
            color: Color(0xffADB5BD),
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        filled: true,
        fillColor: const Color(0xffF7F7FC),
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xffADB5BD), fontSize: 14),
      ),
    );
  }
}
