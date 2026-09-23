import 'package:equatable/equatable.dart';

import 'review.dart';

class Product extends Equatable {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String? brand;
  final List<String> tags;
  final String availabilityStatus;
  final String warrantyInformation;
  final String shippingInformation;
  final String returnPolicy;
  final List<Review> reviews;
  final List<String> images;
  final String thumbnail;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.tags,
    required this.availabilityStatus,
    required this.warrantyInformation,
    required this.shippingInformation,
    required this.returnPolicy,
    required this.reviews,
    required this.images,
    required this.thumbnail,
  });

  /// Price before discount (API price is the final price).
  double get originalPrice =>
      discountPercentage > 0 ? price / (1 - discountPercentage / 100) : price;

  bool get hasDiscount => discountPercentage >= 1;
  bool get inStock => stock > 0;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        category: json['category'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0,
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        stock: (json['stock'] as num?)?.toInt() ?? 0,
        brand: json['brand'] as String?,
        tags: List<String>.from(json['tags'] ?? const []),
        availabilityStatus: json['availabilityStatus'] as String? ?? '',
        warrantyInformation: json['warrantyInformation'] as String? ?? '',
        shippingInformation: json['shippingInformation'] as String? ?? '',
        returnPolicy: json['returnPolicy'] as String? ?? '',
        reviews: (json['reviews'] as List? ?? const [])
            .map((e) => Review.fromJson(e as Map<String, dynamic>))
            .toList(),
        images: List<String>.from(json['images'] ?? const []),
        thumbnail: json['thumbnail'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'price': price,
        'discountPercentage': discountPercentage,
        'rating': rating,
        'stock': stock,
        'brand': brand,
        'tags': tags,
        'availabilityStatus': availabilityStatus,
        'warrantyInformation': warrantyInformation,
        'shippingInformation': shippingInformation,
        'returnPolicy': returnPolicy,
        'reviews': reviews.map((e) => e.toJson()).toList(),
        'images': images,
        'thumbnail': thumbnail,
      };

  @override
  List<Object?> get props => [id];
}

/// Paginated response wrapper: { products, total, skip, limit }.
class ProductPage {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  const ProductPage({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  bool get hasMore => skip + products.length < total;

  factory ProductPage.fromJson(Map<String, dynamic> json) => ProductPage(
        products: (json['products'] as List? ?? const [])
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: (json['total'] as num?)?.toInt() ?? 0,
        skip: (json['skip'] as num?)?.toInt() ?? 0,
        limit: (json['limit'] as num?)?.toInt() ?? 0,
      );
}
