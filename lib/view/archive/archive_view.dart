import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme_constants.dart';
import '../../viewmodel/archive_view_model.dart';
import '../../product/widgets/dialogs/archived_list_detail_dialog.dart';

class ArchiveView extends StatelessWidget {
  const ArchiveView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Arşivlenmiş Listeler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Tamamlanan Listeleriniz',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Consumer<ArchiveViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.archivedLists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppThemeConstants.spacingL),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.archive_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppThemeConstants.spacingM),
                  Text(
                    'Henüz arşivlenmiş liste bulunmuyor',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: AppThemeConstants.spacingS),
                  Text(
                    'Tamamlanan listeleriniz burada görünecek',
                    style: TextStyle(
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

          return ListView.builder(
            padding: const EdgeInsets.all(AppThemeConstants.spacingM),
            itemCount: viewModel.archivedLists.length,
            itemBuilder: (context, index) {
              final archivedList = viewModel.archivedLists[index];
              final dateStr = DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR')
                  .format(DateTime.parse(archivedList.date));

              return Dismissible(
                key: ValueKey('archived_list_${archivedList.id}'),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Listeyi Sil'),
                      content: const Text(
                          'Bu arşivlenmiş listeyi silmek istediğinize emin misiniz?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('İptal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Sil'),
                        ),
                      ],
                    ),
                  );

                  if (result == true) {
                    if (context.mounted) {
                      await viewModel.deleteArchivedList(
                          context, archivedList.id!);
                      toastification.show(
                        // ignore: use_build_context_synchronously
                        context: context,
                        type: ToastificationType.success,
                        style: ToastificationStyle.flatColored,
                        title: const Text('Liste Silindi'),
                        description:
                            const Text('Arşivlenmiş liste başarıyla silindi.'),
                        autoCloseDuration: const Duration(seconds: 3),
                      );
                    }
                    return true;
                  }
                  return false;
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding:
                      const EdgeInsets.only(right: AppThemeConstants.spacingM),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius:
                        BorderRadius.circular(AppThemeConstants.radiusM),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade700,
                  ),
                ),
                child: Card(
                  margin:
                      const EdgeInsets.only(bottom: AppThemeConstants.spacingM),
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => ArchivedListDetailDialog(
                          archivedList: archivedList,
                        ),
                      );
                    },
                    borderRadius:
                        BorderRadius.circular(AppThemeConstants.radiusM),
                    child: Padding(
                      padding: const EdgeInsets.all(AppThemeConstants.spacingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dateStr,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(
                                        height: AppThemeConstants.spacingXS),
                                    Text(
                                      '${archivedList.items.length} Ürün',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppThemeConstants.spacingM,
                                  vertical: AppThemeConstants.spacingS,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                      AppThemeConstants.radiusM),
                                ),
                                child: Text(
                                  '${archivedList.totalAmount.toStringAsFixed(2)} ₺',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
