import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme_constants.dart';

class UpdatePriceDialog extends StatefulWidget {
  final String itemName;
  final double currentPrice;

  const UpdatePriceDialog({
    super.key,
    required this.itemName,
    required this.currentPrice,
  });

  @override
  State<UpdatePriceDialog> createState() => _UpdatePriceDialogState();
}

class _UpdatePriceDialogState extends State<UpdatePriceDialog> {
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _priceController =
        TextEditingController(text: widget.currentPrice.toString());
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppThemeConstants.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppThemeConstants.spacingM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fiyat Güncelle',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppThemeConstants.spacingXS),
            Text(
              widget.itemName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppThemeConstants.spacingM),
            TextField(
              controller: _priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Yeni Fiyat (₺)',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppThemeConstants.radiusM),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppThemeConstants.spacingM,
                  vertical: AppThemeConstants.spacingS,
                ),
              ),
              autofocus: true,
            ),
            const SizedBox(height: AppThemeConstants.spacingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                const SizedBox(width: AppThemeConstants.spacingS),
                ElevatedButton(
                  onPressed: () {
                    final newPrice = double.tryParse(_priceController.text);
                    if (newPrice != null && newPrice > 0) {
                      Navigator.pop(context, newPrice);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: const Text('Kaydet'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
