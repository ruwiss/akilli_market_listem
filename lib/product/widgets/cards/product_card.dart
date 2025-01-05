import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme_constants.dart';
import '../../../core/theme/color_scheme.dart';
import '../../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToList;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToList,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppThemeConstants.spacingS),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppThemeConstants.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppThemeConstants.spacingM),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppThemeConstants.radiusM),
                        child: CachedNetworkImage(
                          imageUrl: 'http://192.168.1.103:8000${product.image}',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 80,
                            height: 80,
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 80,
                            height: 80,
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Material(
                          color: theme.colorScheme.primary,
                          borderRadius:
                              BorderRadius.circular(AppThemeConstants.radiusM),
                          child: InkWell(
                            onTap: onAddToList,
                            borderRadius: BorderRadius.circular(
                                AppThemeConstants.radiusM),
                            child: Container(
                              padding: const EdgeInsets.all(
                                  AppThemeConstants.spacingXS),
                              child: const Icon(
                                Icons.add_shopping_cart,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppThemeConstants.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  AppThemeConstants.radiusS),
                              child: Container(
                                height: 20,
                                constraints: const BoxConstraints(maxWidth: 80),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      'http://192.168.1.103:8000${product.merchantLogo}',
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => Container(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 10,
                                        height: 10,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: Icon(
                                      Icons.store,
                                      color: theme.colorScheme.primary,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppThemeConstants.spacingS),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppThemeConstants.spacingS,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    AppThemeConstants.radiusS),
                              ),
                              child: Text(
                                '${product.quantity} ${product.unit}',
                                style: AppThemeConstants.bodySmall.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppThemeConstants.spacingS),
                        Text(
                          product.brand,
                          style: AppThemeConstants.bodySmall.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppThemeConstants.spacingXS),
                        Text(
                          product.name,
                          style: AppThemeConstants.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppThemeConstants.spacingM),
              Container(
                padding: const EdgeInsets.all(AppThemeConstants.spacingS),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius:
                      BorderRadius.circular(AppThemeConstants.radiusM),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (product.unitPrice > 0) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Birim Fiyat',
                            style: AppThemeConstants.bodySmall.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: AppThemeConstants.spacingXS),
                          Text(
                            '${product.unitPrice.toStringAsFixed(2)} ₺',
                            style: AppThemeConstants.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (product.unitPrice <= 0) SizedBox(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Fiyat',
                          style: AppThemeConstants.bodySmall.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: AppThemeConstants.spacingXS),
                        Text(
                          '${product.price.toStringAsFixed(2)} ₺',
                          style: AppThemeConstants.titleMedium.copyWith(
                            color: AppColorScheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
