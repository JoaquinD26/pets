import 'package:flutter/material.dart';
import 'package:pets/components/commentCard.dart';
import 'package:pets/models/comment.dart';
import 'dart:convert';
//import 'package:http/http.dart' as http;

import 'package:pets/models/forum_model.dart';

class ForumPage extends StatefulWidget {
  ForumPage({super.key});

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
              {"username": "User3", "content": "Comment 2"},
              {"username": "User2", "content": "Comment 1"},
              {"username": "User3", "content": "Comment 2"},
              {"username": "User2", "content": "Comment 1"},
              {"username": "User3", "content": "Comment 2"},
              {"username": "User2", "content": "Comment 1"},
              {"username": "User3", "content": "Comment 2"},
              {"username": "User2", "content": "Comment 1"},
              {"username": "User3", "content": "Comment 2"},
              {"username": "User2", "content": "Comment 1"},
              {"username": "User3", "content": "Comment 2"},
              {"username": "User2", "content": "Comment 1"},
              {"username": "User3", "content": "Comment 2"},
              {"username": "User2", "content": "Comment 1"},
              {"username": "User3", "content": "Comment 2"},
              {"username": "User2", "content": "Comment 1"},
              {"username": "User3", "content": "Comment 2"},
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
      backgroundColor: Colors.deepOrange[100],
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCommentDialog(context);
        },
        backgroundColor: Colors.deepOrangeAccent,
        child: Icon(color: Colors.white, Icons.add),
      ),
    );
  }

  void _showCommentDialog(BuildContext context) {
  TextEditingController commentController = TextEditingController();

  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: 0.9, // Altura del 90% de la pantalla
        alignment: Alignment.topCenter, // Aparece desde arriba
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Añadir Comentario',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.deepOrange,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: 'Escribe tu comentario aquí...',
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  String comment = commentController.text;
                  // Implementa la lógica para enviar el comentario al servidor
                  _postComment(comment);
                  Navigator.pop(context);
                },
                child: Text('Enviar'),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  void _postComment(String comment) {
    // Implementa aquí la lógica para enviar el comentario al servidor
  }
}
