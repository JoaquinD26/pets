import 'package:pets/models/Post.dart';
import 'package:pets/models/User.dart';

class Forum {
  final int id;
  final String name;
  final DateTime date;
  final int likes;
  final String description;
  final User user;
  final List<Post> posts;


  Forum({
    required this.id,
    required this.name,
    required this.date,
    required this.likes,
    required this.description,
    required this.user,
    required this.posts,
  });

  // Factory constructor to create a Forum from JSON
  factory Forum.fromJson(Map<String, dynamic> json) {
    return Forum(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      likes: json['likes'],
      description: json['description'],
      user: json['user'], 
      posts: json['posts'] ?? [],
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
      'user': user,
    };
  }
}