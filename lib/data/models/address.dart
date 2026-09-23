import 'package:equatable/equatable.dart';

class Address extends Equatable {
  final String id;
  final String label; // Home / Work / Other
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String country;
  final bool isDefault;

  const Address({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.country,
    this.isDefault = false,
  });

  String get oneLine => '$street, $city, $country';

  Address copyWith({
    String? label,
    String? fullName,
    String? phone,
    String? street,
    String? city,
    String? country,
    bool? isDefault,
  }) =>
      Address(
        id: id,
        label: label ?? this.label,
        fullName: fullName ?? this.fullName,
        phone: phone ?? this.phone,
        street: street ?? this.street,
        city: city ?? this.city,
        country: country ?? this.country,
        isDefault: isDefault ?? this.isDefault,
      );

  factory Address.fromJson(Map<String, dynamic> j) => Address(
        id: j['id'] as String,
        label: j['label'] as String? ?? 'Home',
        fullName: j['fullName'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        street: j['street'] as String? ?? '',
        city: j['city'] as String? ?? '',
        country: j['country'] as String? ?? '',
        isDefault: j['isDefault'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'fullName': fullName,
        'phone': phone,
        'street': street,
        'city': city,
        'country': country,
        'isDefault': isDefault,
      };

  @override
  List<Object?> get props => [id, label, fullName, phone, street, city, country, isDefault];
}
