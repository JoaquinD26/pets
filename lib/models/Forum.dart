
import 'dart:convert';

import 'package:pets/models/User.dart';

class Forum {
  final int id;
  final String name;
  final DateTime date;
  final int likes;
  final String description;
  final User user;

  Forum({
    required this.id,
    required this.name,
    required this.date,
    required this.likes,
    required this.description,
    required this.user,
  });

  // Factory constructor to create a Forum from JSON
  factory Forum.fromJson(Map<String, dynamic> json) {
    User user = User.fromJson(json['user']);

    return Forum(
      id: json['id'],
      name: json['name'] != null ? utf8.decode(json['name'].toString().codeUnits) : "No llegó",
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      likes: json['likes'] ?? 0,
      description: json['description'] != null ? utf8.decode(json['description'].toString().codeUnits) : "No llegó",
      user: user,
    );
  }

  // Method to convert a Forum to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'likes': likes,
      'description': description,
      'user': user.toJson(), // Assuming User class has a toJson method
    };
  }
}
