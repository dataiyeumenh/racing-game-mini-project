import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/cow_data.dart';

class CowSprite extends StatelessWidget {
  final CowData cow;
  final bool highlighted;

  const CowSprite({super.key, required this.cow, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: highlighted
          ? BoxDecoration(
              border: Border.all(color: Colors.amber, width: 2.5),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Image.asset(
        cow.currentAsset,
        width: kCowSize,
        height: kCowSize,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Container(
          width: kCowSize,
          height: kCowSize,
          decoration: BoxDecoration(
            color: cow.color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              cow.label[0],
              style: const TextStyle(fontSize: 28, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
