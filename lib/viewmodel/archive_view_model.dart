import 'package:flutter/material.dart';
import '../core/init/database_service.dart';
import '../product/models/archived_list.dart';

class ArchiveViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<ArchivedList> _archivedLists = [];
  bool _isLoading = false;

  List<ArchivedList> get archivedLists => _archivedLists;
  bool get isLoading => _isLoading;

  Future<void> loadArchivedLists() async {
    _isLoading = true;
    notifyListeners();

    try {
      final lists = await _databaseService.getArchivedLists();
      _archivedLists = lists;
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
