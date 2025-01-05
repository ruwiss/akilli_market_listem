import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/theme/app_theme_constants.dart';
import '../../../core/theme/color_scheme.dart';
import '../../models/shopping_item.dart';
import '../dialogs/update_price_dialog.dart';

class ShoppingItemCard extends StatelessWidget {
  final ShoppingItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final Function(double) onUpdatePrice;

  const ShoppingItemCard({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
    required this.onUpdatePrice,
  });

  Future<void> _showUpdatePriceDialog(BuildContext context) async {
    final newPrice = await showDialog<double>(
      context: context,
      builder: (context) => UpdatePriceDialog(
        itemName: item.name,
        currentPrice: item.price,
      ),
    );

    if (newPrice != null) {
      onUpdatePrice(newPrice);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          CustomSlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.red.shade100,
            foregroundColor: Colors.red.shade700,
            borderRadius: BorderRadius.circular(AppThemeConstants.radiusM),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline, size: 24),
                const SizedBox(height: 4),
                const Text(
                  'Sil',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppThemeConstants.spacingS),
        child: InkWell(
          onTap: onToggle,
          onLongPress: () => _showUpdatePriceDialog(context),
          borderRadius: BorderRadius.circular(AppThemeConstants.radiusM),
          child: Padding(
            padding: const EdgeInsets.all(AppThemeConstants.spacingM),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: item.isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.isCompleted
                        ? Icons.check
                        : Icons.shopping_cart_outlined,
                    size: 16,
                    color: item.isCompleted
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppThemeConstants.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          decoration: item.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (item.unit != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${item.quantity} ${item.unit}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.totalPrice.toStringAsFixed(2)} ₺',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.unit_price > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${item.unit_price.toStringAsFixed(2)} ₺/birim',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
