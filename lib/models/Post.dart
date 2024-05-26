class Post {
  final int id;
  final String name;
  final String message;
  final int likes;
  final int forumId;
  final int userId; // Referencia al UserModel por ID

  Post({
    required this.id,
    required this.name,
    required this.message,
    required this.likes,
    required this.forumId,
    required this.userId,
  });

  // Factory constructor to create a Post from JSON
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      name: json['name'],
      message: json['message'],
      likes: json['likes'],
      forumId: json['forum']['id'], // assuming forum is a nested object
      userId: json['user']['id'], // assuming user is a nested object
    );
  }

  // Method to convert a Post to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'message': message,
      'likes': likes,
      'forum': {'id': forumId}, // assuming forum is a nested object
      'user': {'id': userId}, // assuming user is a nested object
    };
  }
}
