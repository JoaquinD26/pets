import 'package:pets/models/comment.dart';

class ForumPost {
  final String username;
  final String content;
  final int likes;
  final List<Comment> comments;

  ForumPost({
    required this.username,
    required this.content,
    required this.likes,
    required this.comments,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    // Convertir la lista de comentarios del JSON a una lista de objetos Comment
    List<Comment> comments = (json['comments'] as List)
        .map((commentJson) => Comment.fromJson(commentJson))
        .toList();

    return ForumPost(
      username: json['username'],
      content: json['content'],
      likes: json['likes'],
      comments: comments,
    );
  }
}
