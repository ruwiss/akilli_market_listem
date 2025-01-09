import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme_constants.dart';
import '../../viewmodel/shopping_list_view_model.dart';
import '../../product/widgets/cards/shopping_item_card.dart';
import '../../product/widgets/sections/checkout_section.dart';
import 'package:intl/intl.dart';

class _ListNameDialog extends StatefulWidget {
  const _ListNameDialog({super.key});

  @override
  State<_ListNameDialog> createState() => _ListNameDialogState();
}

class _ListNameDialogState extends State<_ListNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Liste İsmi'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Örn: Market Alışverişi, Haftalık Liste',
          labelText: 'Liste İsmi',
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            Navigator.pop(context, value);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        TextButton(
          onPressed: () {
            final text = _controller.text;
            if (text.isNotEmpty) {
              Navigator.pop(context, text);
            }
          },
          child: const Text('Tamam'),
        ),
      ],
    );
  }
}

class ShoppingListView extends StatelessWidget {
  const ShoppingListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Consumer<ShoppingListViewModel>(
          builder: (context, viewModel, child) => AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alışveriş Listem',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (viewModel.listCreatedDate != null)
                  Text(
                    DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR')
                        .format(viewModel.listCreatedDate!),
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
            centerTitle: false,
          ),
        ),
      ),
      body: Consumer<ShoppingListViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildHeader(context, viewModel),
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
                  showDialog<String>(
                    context: context,
                    builder: (context) => const _ListNameDialog(),
                  ).then((name) {
                    if (name != null && name.isNotEmpty) {
                      viewModel.archiveList(context, name);
                    }
                  });
                },
                isAllCompleted: viewModel.items.isNotEmpty &&
                    viewModel.items.any((item) => item.isCompleted),
                buttonText: 'Listeyi Tamamla',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ShoppingListViewModel viewModel) {
    final completedItems =
        viewModel.items.where((item) => item.isCompleted).length;
    final totalItems = viewModel.items.length;
    final theme = Theme.of(context);
    final percentage =
        totalItems == 0 ? 0 : (completedItems / totalItems * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(AppThemeConstants.spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppThemeConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: AppThemeConstants.spacingM,
        vertical: AppThemeConstants.spacingS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Center(
                        child: Text(
                          '%$percentage',
                          style: AppThemeConstants.titleMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppThemeConstants.spacingM),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$completedItems/$totalItems Ürün',
                          style: AppThemeConstants.titleMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Kalan: ${totalItems - completedItems}',
                          style: AppThemeConstants.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (completedItems == totalItems && totalItems > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppThemeConstants.spacingS,
                    vertical: AppThemeConstants.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(AppThemeConstants.radiusM),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tamamlandı',
                        style: AppThemeConstants.bodySmall.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppThemeConstants.spacingS),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius:
                      BorderRadius.circular(AppThemeConstants.radiusS),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 6,
                width: (MediaQuery.of(context).size.width -
                        (AppThemeConstants.spacingM * 2) -
                        32) *
                    (percentage / 100),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppThemeConstants.radiusS),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
