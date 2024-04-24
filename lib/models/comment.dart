class Comment {
  final String username;
  final String content;

  Comment({
    required this.username,
    required this.content,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      username: json['username'],
      content: json['content'],
    );
  }
}
