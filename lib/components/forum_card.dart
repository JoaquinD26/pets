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
  late bool _imagenError = false;

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
                backgroundImage: _imagenError ? NetworkImage("https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png") : NetworkImage(widget.forum.user.mainImage!),
                onBackgroundImageError: (exception, stackTrace) {
                  // Manejar error en caso de que la imagen no se pueda cargar
                  setState(() {
                    _imagenError = true;
                  });
                },
              ),
              SizedBox(height: 10),
              Text(
                widget.forum.user.id.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(widget.forum.description),
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
                      Text('${widget.forum.likes}'),
                      const SizedBox(
                        width: 15,
                      ),
                      Icon(Icons.comment),
                      SizedBox(width: 5),
                      Text('${widget.forum.posts.length}'),
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
    // Aquí puedes implementar la lógica para dar "me gusta" al post en tu API
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
