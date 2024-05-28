import 'package:flutter/material.dart';
import 'package:pets/components/posts_from_forum.dart'; // Asegúrate de importar correctamente tu componente CommentDetailsPage
import 'package:pets/models/forum.dart';

class ForumPostCard extends StatefulWidget {
  final Forum forum;

  const ForumPostCard({super.key, required this.forum});

  @override
  ForumPostCardState createState() => ForumPostCardState();
}

class ForumPostCardState extends State<ForumPostCard> {
  bool _liked = false;
  bool _imagenError = false;

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
                        ? NetworkImage("https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png")
                        : NetworkImage(widget.forum.user.mainImage ?? "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png"),
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
                        widget.forum.user.name!, // Assuming 'name' exists in the User model
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: _liked
                            ? Icon(Icons.favorite, color: Colors.red)
                            : Icon(Icons.favorite_border),
                        onPressed: () {
                          setState(() {
                            _liked = !_liked;
                          });
                          _likePost();
                        },
                      ),
                      Text('${widget.forum.likes}'),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.comment),
                      SizedBox(width: 5),
                      Text('${widget.forum.posts.length}'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _likePost() {
    // Implement the logic to like the post in your API
  }

  void _showPostDetails() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: PostDetailsPage(forumPost: widget.forum),
          );
        },
      ),
    );
  }
}
