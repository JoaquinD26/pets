
import 'package:pets/models/User.dart';
import 'package:pets/models/post.dart';

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
    User user = User.fromJson(json['user']);
    List<dynamic> jsonData = json['posts'] ?? [];

    List<Post> postsForum = [];
    if (jsonData.isNotEmpty) {
      postsForum = jsonData.map((postData) => Post.fromJson(postData)).toList();
    } else {
      print('No hay posts disponibles.');
    }

    return Forum(
      id: json['id'],
      name: json['name'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      likes: json['likes'] ?? 0,
      description: json['description'] ?? "No llegó",
      user: user,
      posts: postsForum,
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
      'posts': posts.map((post) => post.toJson()).toList(), // Assuming Post class has a toJson method
    };
  }
}
