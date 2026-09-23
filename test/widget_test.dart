import 'package:flutter_test/flutter_test.dart';
import 'package:shop_flow_e_commerce_mobile_app/data/models/product.dart';

void main() {
  test('Product parses DummyJSON payload', () {
    final p = Product.fromJson({
      'id': 1,
      'title': 'Essence Mascara',
      'price': 9.99,
      'discountPercentage': 10,
      'rating': 4.9,
      'stock': 5,
      'images': ['a.png'],
      'thumbnail': 't.png',
    });
    expect(p.title, 'Essence Mascara');
    expect(p.hasDiscount, isTrue);
    expect(p.originalPrice, closeTo(11.1, 0.01));
  });
}
