import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/init/database_service.dart';
import '../core/utils/toast_utils.dart';
import '../product/models/shopping_item.dart';
import '../product/models/product.dart';
import '../product/models/archived_list.dart';
import '../viewmodel/archive_view_model.dart';

class ShoppingListViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<ShoppingItem> _items = [];
  bool _isLoading = false;
  DateTime? _listCreatedDate;

  List<ShoppingItem> get items => _items;
  bool get isLoading => _isLoading;
  DateTime? get listCreatedDate => _listCreatedDate;

  double get totalAmount {
    return _items.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  ShoppingListViewModel() {
    loadItems();
  }

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();

    _items = await _databaseService.getItems();
    if (_items.isNotEmpty && _listCreatedDate == null) {
      _listCreatedDate = DateTime.now();
    } else if (_items.isEmpty) {
      _listCreatedDate = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem(
    BuildContext context,
    String name,
    double price,
    double quantity, {
    String? unit,
    String? description,
  }) async {
    try {
      final item = ShoppingItem(
        name: name,
        price: price,
        quantity: quantity,
        unit: unit,
        description: description,
      );
      await _databaseService.insertItem(item);
      await loadItems();

      ToastUtils.showSuccessToast(
        context,
        title: 'Ürün Eklendi',
        description: '$name başarıyla listeye eklendi.',
      );
    } catch (e) {
      ToastUtils.showErrorToast(
        context,
        title: 'Hata',
        description: 'Ürün eklenirken bir hata oluştu.',
      );
      debugPrint('Ürün eklenirken hata oluştu: $e');
    }
  }

  Future<void> addProductToList(BuildContext context, Product product) async {
    try {
      final item = ShoppingItem(
        name: product.name,
        price: product.price,
        quantity: 1,
        unit: product.unit,
        description: '${product.brand} - ${product.quantity} ${product.unit}',
        imageUrl: product.image,
        marketImageUrl: '/logo.php?id=${product.merchantId}',
      );

      await _databaseService.insertItem(item);
      await loadItems();

      ToastUtils.showSuccessToast(
        context,
        title: 'Ürün Eklendi',
        description: '${product.name} başarıyla listeye eklendi.',
      );
    } catch (e) {
      ToastUtils.showErrorToast(
        context,
        title: 'Hata',
        description: 'Ürün eklenirken bir hata oluştu.',
      );
      debugPrint('Ürün eklenirken hata oluştu: $e');
    }
  }

  Future<void> toggleItem(BuildContext context, ShoppingItem item) async {
    try {
      final updatedItem = ShoppingItem(
        id: item.id,
        name: item.name,
        price: item.price,
        quantity: item.quantity,
        unit: item.unit,
        description: item.description,
        imageUrl: item.imageUrl,
        marketImageUrl: item.marketImageUrl,
        isCompleted: !item.isCompleted,
      );
      await _databaseService.updateItem(updatedItem);
      await loadItems();
    } catch (e) {
      ToastUtils.showErrorToast(
        context,
        title: 'Hata',
        description: 'Ürün durumu güncellenirken bir hata oluştu.',
      );
      debugPrint('Ürün güncellenirken hata oluştu: $e');
    }
  }

  Future<void> deleteItem(BuildContext context, int id, String itemName) async {
    try {
      await _databaseService.deleteItem(id);
      await loadItems();

      ToastUtils.showSuccessToast(
        context,
        title: 'Ürün Silindi',
        description: '$itemName listeden kaldırıldı.',
      );
    } catch (e) {
      ToastUtils.showErrorToast(
        context,
        title: 'Hata',
        description: 'Ürün silinirken bir hata oluştu.',
      );
      debugPrint('Ürün silinirken hata oluştu: $e');
    }
  }

  Future<void> archiveList(BuildContext context, String name) async {
    try {
      if (_items.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Arşivlenecek ürün bulunmuyor')),
          );
        }
        return;
      }

      // Arşiv listesi oluştur
      final archivedList = ArchivedList(
        name: name,
        date: DateTime.now().toString(),
        totalAmount: totalAmount,
        items: _items
            .map((item) => {
                  'name': item.name,
                  'price': item.price,
                  'quantity': item.quantity,
                  'unit': item.unit,
                  'description': item.description,
                  'isCompleted': item.isCompleted,
                })
            .toList(),
      );

      // Ürünleri arşiv formatına dönüştür
      final archivedItems = _items
          .map((item) => ArchivedItem(
                listId: 0, // Bu ID, veritabanına kayıt sırasında güncellenecek
                name: item.name,
                price: item.price,
                quantity: item.quantity,
                unit: item.unit,
                description: item.description,
                isCompleted: item.isCompleted,
              ))
          .toList();

      // Listeyi arşivle
      await _databaseService.archiveCurrentList(archivedList, archivedItems);
      _items.clear();
      notifyListeners();

      if (context.mounted) {
        // Arşiv listesini güncelle
        context.read<ArchiveViewModel>().loadArchivedLists();

        ToastUtils.showSuccessToast(
          context,
          title: 'Liste Arşivlendi',
          description: '$name başarıyla arşivlendi.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(
          context,
          title: 'Hata',
          description: 'Liste arşivlenirken bir hata oluştu',
        );
      }
      debugPrint('Liste arşivlenirken hata oluştu: $e');
    }
  }

  Future<void> updateItemPrice(
      BuildContext context, ShoppingItem item, double newPrice) async {
    try {
      final updatedItem = ShoppingItem(
        id: item.id,
        name: item.name,
        price: newPrice,
        quantity: item.quantity,
        unit: item.unit,
        description: item.description,
        imageUrl: item.imageUrl,
        marketImageUrl: item.marketImageUrl,
        isCompleted: item.isCompleted,
      );
      await _databaseService.updateItem(updatedItem);
      await loadItems();

      if (context.mounted) {
        ToastUtils.showSuccessToast(
          context,
          title: 'Fiyat Güncellendi',
          description:
              '${item.name} için yeni fiyat: ${newPrice.toStringAsFixed(2)} ₺',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(
          context,
          title: 'Hata',
          description: 'Fiyat güncellenirken bir hata oluştu.',
        );
      }
      debugPrint('Fiyat güncellenirken hata oluştu: $e');
    }
  }
}
