import 'package:flutter/material.dart';
import 'package:turnament/constants/app_constants.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({super.key, this.size = 60, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/app_logo.jpg',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
        if (showText) ...[
          const SizedBox(height: 12),
          Text(
            AppConstants.appName.toUpperCase(),
            style: TextStyle(
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
              color: AppColors.onBackground,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: AppColors.primary.withValues(alpha: 0.8),
                  blurRadius: 15,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
