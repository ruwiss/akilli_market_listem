import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme_constants.dart';
import '../viewmodel/shopping_list_view_model.dart';
import '../product/widgets/cards/shopping_item_card.dart';
import '../product/widgets/cards/shopping_summary_card.dart';
import '../product/widgets/sections/checkout_section.dart';

class ShoppingListView extends StatelessWidget {
  const ShoppingListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Alışveriş Listem'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<ShoppingListViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              ShoppingSummaryCard(
                completedItems:
                    viewModel.items.where((item) => item.isCompleted).length,
                totalItems: viewModel.items.length,
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppThemeConstants.spacingM),
                  itemCount: viewModel.items.length,
                  itemBuilder: (context, index) {
                    final item = viewModel.items[index];
                    return ShoppingItemCard(
                      item: item,
                      onToggle: () => viewModel.toggleItem(context, item),
                      onDelete: () =>
                          viewModel.deleteItem(context, item.id!, item.name),
                      onUpdatePrice: (newPrice) =>
                          viewModel.updateItemPrice(context, item, newPrice),
                    );
                  },
                ),
              ),
              CheckoutSection(
                totalAmount: viewModel.totalAmount,
                onCheckout: () {
                  // TODO: Yeni liste oluşturma işlemi
                },
                isAllCompleted: viewModel.items.isNotEmpty &&
                    viewModel.items.every((item) => item.isCompleted),
                buttonText: 'Yeni Liste Oluştur',
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Listelerim',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('3'),
              child: Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: Badge(
              label: Text('3'),
              child: Icon(Icons.shopping_cart),
            ),
            label: 'Sepetim',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Favoriler',
          ),
        ],
        currentIndex: 2,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}
