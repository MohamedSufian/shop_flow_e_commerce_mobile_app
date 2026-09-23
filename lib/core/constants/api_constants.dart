/// All endpoints of the DummyJSON products API.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://dummyjson.com';

  static const String products = '/products';
  static const String search = '/products/search';
  static const String categories = '/products/categories';
  static String productById(int id) => '/products/$id';
  static String productsByCategory(String slug) => '/products/category/$slug';

  static const int pageSize = 20;
}
