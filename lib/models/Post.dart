import 'dart:convert';

import 'package:pets/models/Forum.dart';
import 'package:pets/models/user.dart';

class Post {
  bool likedByUser = false;
  final int id;
  final String text;
  // final int likes;
  final String date;
  final Forum? forum;
  final User user; // Referencia al UserModel

  Post({
    required this.id,
    required this.text,
    // required this.likes,
    required this.date,
    required this.forum,
    required this.user,
  });

  // Factory constructor to create a Post from JSON
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      text: utf8.decode(json['text'].toString().codeUnits),
      date: json['date'],
      // likes: json['likes'],
        forum: json['forum'] != null ? Forum.fromJson(json['forum']) : null,
      user: User.fromJson(json['user'])// Assuming User.fromJson is available
    );
  }

  // Method to convert a Post to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': utf8.encode(text),
      'date': date,
      // 'likes': likes,
      'forum': forum!.toJson(), // assuming forum is a nested object
      'user': user.toJson(), // Assuming User.toJson is available
    };
  }
}
