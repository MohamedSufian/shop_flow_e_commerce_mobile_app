import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String slug;
  final String name;

  const Category({required this.slug, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        slug: json['slug'] as String? ?? '',
        name: json['name'] as String? ?? '',
      );

  @override
  List<Object?> get props => [slug];
}
