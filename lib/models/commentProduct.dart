import 'dart:convert';

class Rating {
  final String text;
  final int productId;
  final int userId;
  final double userScore;

  Rating({
    required this.text,
    required this.productId,
    required this.userId,
    required this.userScore,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      text: utf8.decode(json['text'].toString().codeUnits),
      productId: json['product_id'],
      userId: json['user_id'],
      userScore: json['user_score'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'product_id': productId,
      'user_id': userId,
      'user_score': userScore,
    };
  }
}
