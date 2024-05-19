import 'package:flutter/material.dart';
import 'package:pets/components/commentDetailsPage.dart';
import 'package:pets/models/forum_model.dart';

class ForumPostCard extends StatefulWidget {
  final ForumPost forumPost;

  ForumPostCard({required this.forumPost});

  @override
  ForumPostCardState createState() => ForumPostCardState();
}

class ForumPostCardState extends State<ForumPostCard> {
  bool _liked = false;
  late bool imagen = true;

  @override
  Widget build(BuildContext context) {
    
    return Card(
      margin: EdgeInsets.all(10),
      child: InkWell(
        onTap: () {
          _showPostDetails();
        },
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20, // Tamaño del círculo
                backgroundImage: imagen ? NetworkImage(
                    "https://imgs.search.brave.com/gPisSlV1_hN5ejTCiWGdG8XCdQjhz-LX8W_6MTO1UcQ/rs:fit:860:0:0/g:ce/aHR0cHM6Ly93d3cu/YmxvZ2RlbGZvdG9n/cmFmby5jb20vd3At/Y29udGVudC91cGxv/YWRzLzIwMjIvMDEv/bG9iby1mb3RvLXBl/cmZpbC53ZWJw") : NetworkImage("https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png"),
                onBackgroundImageError: (exception, stackTrace) {
                  // Manejar error en caso de que la imagen no se pueda cargar
                  imagen = false;
                  setState(() {
                    
                  });
                },
              ),
              SizedBox(height: 10,),
              Text(
                widget.forumPost.username,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(widget.forumPost.content),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: _liked
                            ? Icon(color: Colors.red, Icons.favorite)
                            : Icon(Icons.favorite_border),
                        onPressed: () {
                          setState(() {
                            _liked = !_liked;
                          });
                          _likePost();
                        },
                      ),
                      Text('${widget.forumPost.likes}'),
                      const SizedBox(
                        width: 15,
                      ),
                      Icon(Icons.comment),
                      SizedBox(width: 5),
                      Text('${widget.forumPost.comments.length}'),
                      const SizedBox(
                        width: 10,
                      ),
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
    // Implementa la lógica para dar "me gusta" al post
  }

  void _showPostDetails() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: PostDetailsPage(forumPost: widget.forumPost),
          );
        },
      ),
    );
  }
}
