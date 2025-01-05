import 'package:akilli_market_listem/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/init/api_service.dart';
import '../../core/theme/app_theme_constants.dart';
import '../../core/theme/color_scheme.dart';
import '../../viewmodel/product_search_view_model.dart';
import '../../product/widgets/cards/product_card.dart';
import '../../product/widgets/dialogs/product_detail_dialog.dart';
import '../../viewmodel/shopping_list_view_model.dart';

class ProductSearchView extends StatelessWidget {
  const ProductSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductSearchViewModel(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Ürün Ara'),
          actions: [
            Consumer<ProductSearchViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.products.isEmpty) return const SizedBox();
                return IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.filter_list,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  onPressed: () => _showSortDialog(context, viewModel),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: Consumer<ProductSearchViewModel>(
                builder: (context, viewModel, _) {
                  if (viewModel.isLoading && viewModel.products.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (viewModel.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Bir hata oluştu',
                            style: AppThemeConstants.titleMedium,
                          ),
                          const SizedBox(height: AppThemeConstants.spacingS),
                          Text(
                            viewModel.errorMessage ?? 'Bilinmeyen hata',
                            style: AppThemeConstants.bodySmall,
                          ),
                          const SizedBox(height: AppThemeConstants.spacingM),
                          ElevatedButton(
                            onPressed: viewModel.searchProducts,
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (viewModel.products.isEmpty &&
                      viewModel.searchQuery.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.5),
                          ),
                          const SizedBox(height: AppThemeConstants.spacingM),
                          Text(
                            'Ürün aramak için yukarıdaki\narama çubuğunu kullanın',
                            style: AppThemeConstants.bodyMedium.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (viewModel.products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .error
                                .withOpacity(0.5),
                          ),
                          const SizedBox(height: AppThemeConstants.spacingM),
                          Text(
                            'Aramanızla eşleşen ürün bulunamadı',
                            style: AppThemeConstants.bodyMedium.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                        viewModel.loadMore();
                      }
                      return true;
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppThemeConstants.spacingM),
                      itemCount: viewModel.products.length +
                          (viewModel.hasNext ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == viewModel.products.length) {
                          return const Center(
                            child: Padding(
                              padding:
                                  EdgeInsets.all(AppThemeConstants.spacingM),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final product = viewModel.products[index];
                        return ProductCard(
                          product: product,
                          onTap: () async {
                            await viewModel.showProductDetail(product.url);
                            if (viewModel.selectedProduct != null &&
                                context.mounted) {
                              showDialog(
                                context: context,
                                builder: (context) => ProductDetailDialog(
                                  productDetail: viewModel.selectedProduct!,
                                  productImage: product.image,
                                ),
                              );
                            }
                          },
                          onAddToList: () async {
                            try {
                              await context
                                  .read<ShoppingListViewModel>()
                                  .addProductToList(context, product);
                            } catch (e) {
                              if (context.mounted) {
                                ToastUtils.showErrorToast(
                                  context,
                                  title: 'Hata',
                                  description:
                                      'Ürün eklenirken bir hata oluştu',
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Consumer<ProductSearchViewModel>(
      builder: (context, viewModel, _) {
        return Container(
          padding: const EdgeInsets.all(AppThemeConstants.spacingM),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            onChanged: viewModel.onSearchQueryChanged,
            decoration: InputDecoration(
              hintText: 'Ürün adı yazın...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppThemeConstants.radiusL),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppThemeConstants.spacingM,
                vertical: AppThemeConstants.spacingS,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSortDialog(BuildContext context, ProductSearchViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sıralama'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuItem<SortType>(
              value: SortType.priceAsc,
              child: ListTile(
                title: const Text('En Düşük Fiyat'),
                leading: Radio<SortType>(
                  value: SortType.priceAsc,
                  groupValue: viewModel.sortType,
                  onChanged: (value) {
                    viewModel.setSortType(value);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            PopupMenuItem<SortType>(
              value: SortType.priceDesc,
              child: ListTile(
                title: const Text('En Yüksek Fiyat'),
                leading: Radio<SortType>(
                  value: SortType.priceDesc,
                  groupValue: viewModel.sortType,
                  onChanged: (value) {
                    viewModel.setSortType(value);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
