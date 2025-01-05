import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_constants.dart';
import '../indicators/circular_progress_with_percentage.dart';

class ShoppingSummaryCard extends StatelessWidget {
  final int completedItems;
  final int totalItems;

  const ShoppingSummaryCard({
    super.key,
    required this.completedItems,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(AppThemeConstants.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppThemeConstants.spacingM),
        child: Row(
          children: [
            CircularProgressWithPercentage(
              value: totalItems == 0 ? 0 : completedItems / totalItems,
            ),
            const SizedBox(width: AppThemeConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alışveriş Durumu',
                    style: AppThemeConstants.titleMedium,
                  ),
                  const SizedBox(height: AppThemeConstants.spacingXS),
                  Text(
                    '$completedItems / $totalItems ürün tamamlandı',
                    style: AppThemeConstants.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
