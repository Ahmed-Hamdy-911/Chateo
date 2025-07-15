
import 'package:flutter/material.dart';
import 'custom_build_image_style.dart';
import 'custom_text.dart';

class CustomContactItem extends StatelessWidget {
  const CustomContactItem({
    super.key,
    required this.name,
    this.message = '', this.onTap,
  });
  final String name;
  final String? message;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.1,
        child: Row(
          children: [
            CustomBuildImageStyle(
              name: name,
            ),
            const SizedBox(
              width: 15,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: name,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  width: MediaQuery.of(context).size.width * 0.62,
                ),
                const SizedBox(
                  height: 3,
                ),
                CustomText(
                  text: message!,
                  width: MediaQuery.of(context).size.width * 0.7,
                  fontSize: 13,
                  color: const Color(0xffADB5BD),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
