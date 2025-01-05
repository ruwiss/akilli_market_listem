import 'dart:async';
import 'package:flutter/material.dart';
import '../core/init/api_service.dart';
import '../product/models/product.dart';

class ProductSearchViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final List<Product> _products = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  String _searchQuery = '';
  SortType? _sortType;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasNext = false;
  Timer? _debounceTimer;
  ProductDetail? _selectedProduct;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  SortType? get sortType => _sortType;
  bool get hasNext => _hasNext;
  ProductDetail? get selectedProduct => _selectedProduct;

  void onSearchQueryChanged(String query) {
    _searchQuery = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _currentPage = 1;
        _products.clear();
        searchProducts();
      }
    });
  }

  void setSortType(SortType? type) {
    _sortType = type;
    if (_searchQuery.isNotEmpty) {
      _currentPage = 1;
      _products.clear();
      searchProducts();
    }
  }

  Future<void> searchProducts() async {
    if (_searchQuery.isEmpty) return;

    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.searchProducts(
        query: _searchQuery,
        sortType: _sortType,
        page: _currentPage,
      );

      if (_currentPage == 1) {
        _products.clear();
      }
      _products.addAll(response.data);
      _currentPage = response.currentPage;
      _totalPages = response.totalPages;
      _hasNext = response.hasNext;
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasNext) return;
    _currentPage++;
    await searchProducts();
  }

  Future<void> showProductDetail(String url) async {
    try {
      _selectedProduct = await _apiService.getProductDetail(url);
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearProductDetail() {
    _selectedProduct = null;
    notifyListeners();
  }

  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
