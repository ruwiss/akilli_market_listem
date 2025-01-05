import 'package:flutter/material.dart';
import '../../../core/theme/color_scheme.dart';

class CircularProgressWithPercentage extends StatelessWidget {
  final double value;
  final double size;
  final double strokeWidth;

  const CircularProgressWithPercentage({
    super.key,
    required this.value,
    this.size = 48,
    this.strokeWidth = 4,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            backgroundColor: AppColorScheme.primaryColor.withOpacity(0.2),
            color: AppColorScheme.primaryColor,
            strokeWidth: strokeWidth,
          ),
          Text(
            '${(value * 100).toInt()}%',
            style: TextStyle(
              fontSize: size * 0.3,
              fontWeight: FontWeight.bold,
              color: AppColorScheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
