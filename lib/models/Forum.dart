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

    // Si el campo user ya es un Map, no es necesario decodificarlo nuevamente.
    User user = User.fromJson(json['user']);

    // // Mapear la lista de posts
    // List<Post> posts = (jsonDecode(json['post']) as List<dynamic>).map((post) => Post.fromJson(post)).toList();

    // List<dynamic> jsonData = jsonDecode(json['post']);

    List<dynamic> jsonData = json['post'];

    List<Post> postsForum = [];

    // Verifica si jsonData es una lista y no está vacía
    if (jsonData.isNotEmpty) {
      // Si jsonData es una lista y no está vacía, convierte cada elemento en un objeto Post
      postsForum = jsonData.map((postData) => Post.fromJson(postData)).toList();
    } else {
      // Si jsonData no es una lista o está vacía, imprime un mensaje o toma alguna acción adecuada
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
      'user': user,
    };
  }
}