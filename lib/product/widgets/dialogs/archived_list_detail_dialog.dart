import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_constants.dart';
import '../../models/archived_list.dart';
import 'package:intl/intl.dart';

class ArchivedListDetailDialog extends StatelessWidget {
  final ArchivedList archivedList;

  const ArchivedListDetailDialog({
    super.key,
    required this.archivedList,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR')
        .format(DateTime.parse(archivedList.date));

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppThemeConstants.radiusL),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppThemeConstants.spacingM),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Arşivlenmiş Liste',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: AppThemeConstants.spacingL),
            Expanded(
              child: ListView.separated(
                itemCount: archivedList.items.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: AppThemeConstants.spacingM),
                itemBuilder: (context, index) {
                  final item = archivedList.items[index];
                  return Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppThemeConstants.radiusM),
                        ),
                        child: Center(
                          child: Icon(
                            item['isCompleted'] == true
                                ? Icons.check_circle
                                : Icons.shopping_cart_outlined,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppThemeConstants.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (item['unit'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${item['quantity']} ${item['unit']}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Text(
                        '${(item['price'] * item['quantity']).toStringAsFixed(2)} ₺',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const Divider(height: AppThemeConstants.spacingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Toplam Tutar',
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      '${archivedList.items.length} Ürün',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${archivedList.totalAmount.toStringAsFixed(2)} ₺',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
