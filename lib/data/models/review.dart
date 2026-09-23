import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final int rating;
  final String comment;
  final DateTime? date;
  final String reviewerName;

  const Review({
    required this.rating,
    required this.comment,
    required this.date,
    required this.reviewerName,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        comment: json['comment'] as String? ?? '',
        date: DateTime.tryParse(json['date'] as String? ?? ''),
        reviewerName: json['reviewerName'] as String? ?? 'Anonymous',
      );

  Map<String, dynamic> toJson() => {
        'rating': rating,
        'comment': comment,
        'date': date?.toIso8601String(),
        'reviewerName': reviewerName,
      };

  @override
  List<Object?> get props => [rating, comment, date, reviewerName];
}
