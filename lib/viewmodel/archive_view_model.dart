import 'package:flutter/material.dart';
import '../core/init/database_service.dart';
import '../product/models/archived_list.dart';

class ArchiveViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<ArchivedList> _archivedLists = [];
  bool _isLoading = false;
  bool _sortOldestFirst = false;

  List<ArchivedList> get archivedLists => _archivedLists;
  bool get isLoading => _isLoading;
  bool get sortOldestFirst => _sortOldestFirst;

  void setSortOrder(bool oldestFirst) {
    _sortOldestFirst = oldestFirst;
    _sortLists();
    notifyListeners();
  }

  void _sortLists() {
    _archivedLists.sort((a, b) {
      final dateA = DateTime.parse(a.date);
      final dateB = DateTime.parse(b.date);
      return _sortOldestFirst ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });
  }

  Future<void> loadArchivedLists() async {
    _isLoading = true;
    notifyListeners();

    try {
      final lists = await _databaseService.getArchivedLists();
      _archivedLists = lists;
      _sortLists();
    } catch (e) {
      debugPrint('Arşivlenmiş listeler yüklenirken hata: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteArchivedList(BuildContext context, int id) async {
    try {
      await _databaseService.deleteArchivedList(id);
      _archivedLists.removeWhere((list) => list.id == id);
      notifyListeners();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Liste silinirken bir hata oluştu')),
        );
      }
    }
  }
}
