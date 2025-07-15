import 'package:flutter/material.dart';

import 'custom_text.dart';

class CustomProfileItem extends StatelessWidget {
  const CustomProfileItem({
    super.key,
    required this.subtitle,
    required this.title,
    required this.icon,
  });
  final String subtitle;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        child: ListTile(
          leading: Icon(icon),
          title: CustomText(
            text: title,
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          subtitle: CustomText(
              text: subtitle, maxLines: subtitle.length > 300 ? 8 : null),
        ),
      ),
    );
  }
}
