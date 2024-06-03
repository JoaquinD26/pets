import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pets/components/posts_from_forum.dart'; // Asegúrate de importar correctamente tu componente CommentDetailsPage
import 'package:pets/models/forum.dart';
import 'package:pets/models/post.dart';
import 'package:pets/models/user.dart';
import 'package:http/http.dart' as http;

class ForumPostCard extends StatefulWidget {
  final Forum forum;
  final User userLog;

  ForumPostCard({super.key, required this.forum, required this.userLog});

  @override
  ForumPostCardState createState() => ForumPostCardState();
}

class ForumPostCardState extends State<ForumPostCard> {
  bool _imagenError = false;
  int numeroPosts = 0;

  Future<int> forumPostsLength(int forumId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/post/forum/$forumId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        // Mapea los datos de la respuesta a objetos Post
        List<Post> posts =
            responseData.map((data) => Post.fromJson(data)).toList();

        return posts.length;
      } else {
        throw Exception(
            'Failed to load posts for forum: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to load posts for forum: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCommentsLength();
  }

  Future<void> _loadCommentsLength() async {
    try {
      int posts = await forumPostsLength(widget.forum.id);

      setState(() {
        numeroPosts = posts;
      });
    } catch (e) {
      print('Error loading comments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: InkWell(
        onTap: () {
          _showPostDetails();
        },
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: _imagenError
                        ? NetworkImage(
                            "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png")
                        : NetworkImage(
                            "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png"),
                    onBackgroundImageError: (exception, stackTrace) {
                      setState(() {
                        _imagenError = true;
                      });
                    },
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.forum.user
                            .name!, // Assuming 'name' exists in the User model
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        widget.forum.date.toLocal().toString().split(' ')[0],
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                widget.forum.name, // Assuming 'name' is the title of the forum
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                widget.forum.description,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.comment),
                  SizedBox(width: 5),
                  Text('${numeroPosts}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPostDetails() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) =>
            PostDetailsPage(forumPost: widget.forum, userLog: widget.userLog),
      ),
    )
        .then((_) {
      _loadCommentsLength();
    });
  }
}
