import 'package:flutter/material.dart';
import 'package:proj/colors.dart';

// ignore: must_be_immutable
class LikeButton extends StatelessWidget {
  final bool isLiked;
  void Function()? onTap;
  LikeButton({super.key, required this.isLiked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        isLiked ? Icons.favorite : Icons.favorite_border,
        color: isLiked ? ColorPalette.darkblue : ColorPalette.darkblue,
      ),
    );
  }
}
