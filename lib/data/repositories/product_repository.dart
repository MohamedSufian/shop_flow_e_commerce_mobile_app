import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/category.dart';
import '../models/product.dart';

class ProductRepository {
  ProductRepository(this._api);

  final ApiClient _api;

  Future<ProductPage> getProducts({
    int skip = 0,
    int limit = ApiConstants.pageSize,
    String? sortBy,
    String order = 'asc',
  }) async {
    final data = await _api.get(ApiConstants.products, query: {
      'skip': skip,
      'limit': limit,
      if (sortBy != null) 'sortBy': sortBy,
      if (sortBy != null) 'order': order,
    });
    return ProductPage.fromJson(data as Map<String, dynamic>);
  }

  Future<ProductPage> searchProducts(String query, {int skip = 0, int limit = ApiConstants.pageSize}) async {
    final data = await _api.get(ApiConstants.search, query: {
      'q': query,
      'skip': skip,
      'limit': limit,
    });
    return ProductPage.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Category>> getCategories() async {
    final data = await _api.get(ApiConstants.categories) as List;
    return data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ProductPage> getProductsByCategory(String slug, {int skip = 0, int limit = ApiConstants.pageSize}) async {
    final data = await _api.get(ApiConstants.productsByCategory(slug), query: {
      'skip': skip,
      'limit': limit,
    });
    return ProductPage.fromJson(data as Map<String, dynamic>);
  }

  Future<Product> getProduct(int id) async {
    final data = await _api.get(ApiConstants.productById(id));
    return Product.fromJson(data as Map<String, dynamic>);
  }
}
