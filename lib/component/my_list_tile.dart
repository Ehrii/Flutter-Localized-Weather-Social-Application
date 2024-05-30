import 'package:flutter/material.dart';
import 'package:proj/colors.dart';

class MyListTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onTap;
  MyListTile({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: ColorPalette.lightblue,
        ),
        onTap: onTap,
        title: Text(text,
            style: const TextStyle(
              color: ColorPalette.lightblue,
            )),
      ),
    );
  }
}
