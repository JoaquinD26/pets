import 'package:flutter/material.dart';
import 'package:pets/models/forum_model.dart';

class ForumPostCard extends StatefulWidget {
  final ForumPost forumPost;

  ForumPostCard({required this.forumPost});

  @override
  ForumPostCardState createState() => ForumPostCardState();
}

class ForumPostCardState extends State<ForumPostCard> {
  bool _expanded = false;
  bool _liked = false;
  bool _showCommentField = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: InkWell(
        onTap: () {
          setState(() {
            _expanded = !_expanded;
            _showCommentField = !_showCommentField;
          });
        },
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: _liked
                            ? Icon(Icons.favorite)
                            : Icon(Icons.favorite_border),
                        onPressed: () {
                          setState(() {
                            _liked = !_liked;
                          });
                          _likePost();
                        },
                      ),
                      SizedBox(width: 5),
                      Text('${widget.forumPost.likes}'),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.comment),
                      SizedBox(width: 5),
                      Text('${widget.forumPost.comments.length}'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              if (_expanded)
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.forumPost.comments.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ListTile(
                          title:
                              Text(widget.forumPost.comments[index].username),
                          subtitle:
                              Text(widget.forumPost.comments[index].content),
                        ),
                      ],
                    );
                  },
                ),
              if (_showCommentField)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Responder comentario aquí...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          // implementar respuesta de comentario
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _likePost() {
    // implementar añadir megustas
  }
}
