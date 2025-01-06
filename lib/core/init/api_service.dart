import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../../product/models/product.dart';

enum SortType {
  priceAsc,
  priceDesc,
}

extension SortTypeExtension on SortType {
  String get value {
    switch (this) {
      case SortType.priceAsc:
        return 'price-asc';
      case SortType.priceDesc:
        return 'price-desc';
    }
  }
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.apiUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  Future<ApiResponse<List<Product>>> searchProducts({
    required String query,
    SortType? sortType,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/api.php',
        queryParameters: {
          'q': query,
          if (sortType != null) 'sort': sortType.value,
          'page': page,
        },
      );

      if (response.data['success'] == true) {
        final products = (response.data['products'] as List)
            .map((json) => Product.fromJson(json))
            .toList();

        return ApiResponse(
          data: products,
          currentPage: response.data['pagination']['current_page'],
          totalPages: response.data['pagination']['total_pages'],
          hasNext: response.data['pagination']['has_next'],
          hasPrevious: response.data['pagination']['has_previous'],
          total: response.data['total'],
        );
      }

      throw Exception('API request failed');
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  Future<ProductDetail> getProductDetail(String url) async {
    try {
      final response = await _dio.get(url);

      if (response.data['success'] == true) {
        return ProductDetail.fromJson(response.data['product']);
      }

      throw Exception('API request failed');
    } catch (e) {
      throw Exception('Failed to get product detail: $e');
    }
  }
}

class ApiResponse<T> {
  final T data;
  final int currentPage;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;
  final int total;

  ApiResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
    required this.total,
  });
}
