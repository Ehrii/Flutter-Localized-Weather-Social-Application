import 'package:flutter/material.dart';
import 'package:proj/colors.dart';

class MyTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final void Function()? onPressed;
  const MyTextBox({super.key, required this.text, required this.sectionName, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.mediumdarkblue.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(left: 15, bottom: 15),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sectionName,
                style: const TextStyle(color: ColorPalette.blue, fontWeight: FontWeight.w400),
              ),
              IconButton(
                onPressed: onPressed,
                icon: const Icon(
                  Icons.settings,
                  color: ColorPalette.darkblue,
                ),
              )
            ],
          ),
          Text(text),
        ],
      ),
    );
  }
}
