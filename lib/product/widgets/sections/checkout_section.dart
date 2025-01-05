import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_constants.dart';
import '../../../core/theme/color_scheme.dart';

class CheckoutSection extends StatelessWidget {
  final double totalAmount;
  final VoidCallback onCheckout;
  final bool isAllCompleted;
  final String buttonText;

  const CheckoutSection({
    super.key,
    required this.totalAmount,
    required this.onCheckout,
    required this.isAllCompleted,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppThemeConstants.spacingM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Toplam Tutar',
                  style: AppThemeConstants.bodySmall.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: AppThemeConstants.spacingXS),
                Text(
                  '${totalAmount.toStringAsFixed(2)} ₺',
                  style: AppThemeConstants.titleLarge.copyWith(
                    color: AppColorScheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: isAllCompleted ? onCheckout : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppThemeConstants.spacingL,
                vertical: AppThemeConstants.spacingM,
              ),
              backgroundColor: AppColorScheme.primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  AppColorScheme.primaryColor.withOpacity(0.3),
              disabledForegroundColor: Colors.white.withOpacity(0.5),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
