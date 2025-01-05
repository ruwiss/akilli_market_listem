import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme_constants.dart';
import '../core/init/api_service.dart';
import '../viewmodel/product_search_view_model.dart';
import '../viewmodel/shopping_list_view_model.dart';
import '../product/widgets/cards/product_card.dart';
import '../product/widgets/dialogs/product_detail_dialog.dart';

class ProductSearchView extends StatelessWidget {
  const ProductSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProductSearchViewModel, ShoppingListViewModel>(
      builder: (context, searchViewModel, listViewModel, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Ürün Ara'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Padding(
                padding: const EdgeInsets.all(AppThemeConstants.spacingM),
                child: TextField(
                  onChanged: searchViewModel.onSearchQueryChanged,
                  decoration: InputDecoration(
                    hintText: 'Ürün adı veya markası',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppThemeConstants.radiusM),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              if (searchViewModel.sortType != null ||
                  searchViewModel.products.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppThemeConstants.spacingM,
                    vertical: AppThemeConstants.spacingS,
                  ),
                  color: Theme.of(context).colorScheme.surface,
                  child: Row(
                    children: [
                      const Text('Sırala:'),
                      const SizedBox(width: AppThemeConstants.spacingS),
                      ChoiceChip(
                        label: const Text('En Düşük Fiyat'),
                        selected: searchViewModel.sortType == SortType.priceAsc,
                        onSelected: (selected) => searchViewModel
                            .setSortType(selected ? SortType.priceAsc : null),
                      ),
                      const SizedBox(width: AppThemeConstants.spacingXS),
                      ChoiceChip(
                        label: const Text('En Yüksek Fiyat'),
                        selected:
                            searchViewModel.sortType == SortType.priceDesc,
                        onSelected: (selected) => searchViewModel
                            .setSortType(selected ? SortType.priceDesc : null),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: searchViewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : searchViewModel.hasError
                        ? Center(
                            child: Text(searchViewModel.errorMessage ??
                                'Bir hata oluştu'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(
                                AppThemeConstants.spacingM),
                            itemCount: searchViewModel.products.length,
                            itemBuilder: (context, index) {
                              final product = searchViewModel.products[index];
                              return ProductCard(
                                product: product,
                                onTap: () async {
                                  await searchViewModel
                                      .showProductDetail(product.url);
                                  if (context.mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => ProductDetailDialog(
                                        productDetail:
                                            searchViewModel.selectedProduct!,
                                        productImage: product.image,
                                      ),
                                    );
                                  }
                                },
                                onAddToList: () {
                                  listViewModel.addProductToList(
                                      context, product);
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
