import 'package:flutter/material.dart';
import 'package:pets/models/comment.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:pets/models/forum_model.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  ForumPageState createState() => ForumPageState();
}

class ForumPageState extends State<ForumPage> {
  List<ForumPost> forumPosts = [];

  @override
  void initState() {
    super.initState();
    // Load forum posts when the page initializes
    loadForumPosts();
  }

  ///Método con api de pruebas

  /*void loadForumPosts() async {
    try {
      // Realizar la solicitud HTTP GET a la API
      var response = await http
          .get(Uri.parse('http://localhost/pruebaApiPets/comments.php'));

      // Verificar si la solicitud fue exitosa (código de respuesta 200)
      if (response.statusCode == 200) {
        // Decodificar la cadena JSON
        Map<String, dynamic> jsonData = json.decode(response.body);

        // Obtener la lista de publicaciones del foro del campo 'data'
        List<dynamic> postData = jsonData['data'];

        // Crear objetos ForumPost
        List<ForumPost> loadedPosts = postData.map((post) {
          // Convertir los comentarios de cada post a objetos Comment
          List<Comment> comments = [];
          for (var comment in post['comments']) {
            comments.add(Comment(
              username: comment['username'],
              content: comment['content'],
            ));
          }
          // Crear el objeto ForumPost con los datos del post y los comentarios
          return ForumPost(
            username: post['username'],
            content: post['content'],
            likes: post['likes'],
            comments: comments,
          );
        }).toList();

        // Actualizar el estado con las publicaciones del foro obtenidas de la API
        setState(() {
          forumPosts = loadedPosts;
        });
      } else {
        // Si la solicitud no fue exitosa, imprimir el código de respuesta
        print(
            'Error al cargar los posts del foro. Código de respuesta: ${response.statusCode}');
      }
    } catch (e) {
      // Manejar cualquier error que ocurra durante la solicitud
      print('Error al cargar los posts del foro: $e');
    }
  }*/

  ///Método fijo 
void loadForumPosts() async {
    // Simulate loading forum posts from a server
    String jsonString = '''
      {
        "success": true,
        "message": "Forum posts loaded successfully.",
        "data": [
          {
            "username": "User1",
            "content": "First forum post content",
            "likes": 10,
            "comments": [
              {"username": "User2", "content": "Comment 1"},
              {"username": "User3", "content": "Comment 2"}
            ]
          },
          {
            "username": "User4",
            "content": "Second forum post content",
            "likes": 20,
            "comments": [
              {"username": "User5", "content": "Comment 3"}
            ]
          }
        ]
      }
    ''';

    // Decode JSON string
    Map<String, dynamic> jsonData = json.decode(jsonString);
    List<dynamic> postData = jsonData['data'];

    // Create ForumPost objects
    List<ForumPost> loadedPosts = postData.map((post) {
      List<Comment> comments = [];
      for (var comment in post['comments']) {
        comments.add(Comment(
          username: comment['username'],
          content: comment['content'],
        ));
      }
      return ForumPost(
        username: post['username'],
        content: post['content'],
        likes: post['likes'],
        comments: comments,
      );
    }).toList();

    setState(() {
      forumPosts = loadedPosts;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              itemCount: forumPosts.length,
              itemBuilder: (context, index) {
                return ForumPostCard(
                  forumPost: forumPosts[index],
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Escribe tu comentario aquí...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // Implement functionality to post comment as a reply
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20,)
        ],
      ),
    );
  }
}

class ForumPostCard extends StatefulWidget {
  final ForumPost forumPost;

  ForumPostCard({required this.forumPost});

  @override
  _ForumPostCardState createState() => _ForumPostCardState();
}

class _ForumPostCardState extends State<ForumPostCard> {
  bool _expanded = false;
  bool _liked = false;
  bool _showCommentField = false; // Track if comment field is visible

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
                            hintText: 'Escribe tu comentario aquí...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          // Implement functionality to post comment as a reply
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
    // Implement like functionality
  }
}
