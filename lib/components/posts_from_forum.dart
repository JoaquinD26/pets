import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:pets/models/forum.dart';
import 'package:pets/models/post.dart';
import 'package:pets/models/user.dart';
import 'package:http/http.dart' as http;

class PostDetailsPage extends StatefulWidget {
  final Forum forumPost;
  final User userLog;

  PostDetailsPage({super.key, required this.forumPost, required this.userLog});

  @override
  PostDetailsPageState createState() => PostDetailsPageState();
}

Future<List<Post>> fetchPostsForForum(int forumId) async {
  try {
    final response = await http.get(
      Uri.parse('http://localhost:3000/post/forum/$forumId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      // Mapea los datos de la respuesta a objetos Post
      List<Post> posts =
          responseData.map((data) => Post.fromJson(data)).toList();
      return posts;
    } else {
      throw Exception(
          'Failed to load posts for forum: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Failed to load posts for forum: $e');
  }
}

class PostDetailsPageState extends State<PostDetailsPage> {
  List<Post> postsList = [];

  TextEditingController replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      List<Post> posts = await fetchPostsForForum(widget.forumPost.id);

      setState(() {
        postsList = posts;
      });
    } catch (e) {
      print('Error loading comments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles del Post',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepOrange[300],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          color: Colors.red,
                          onPressed: () {
                            print("hola");
                          },
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    ),
                    SizedBox(
                        height:
                            16), // Espacio adicional entre el botón y los demás elementos
                    Text(
                      widget.forumPost.user.name!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.forumPost.description,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Comentarios',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: postsList.length,
                itemBuilder: (context, index) {
                  final userName = postsList[index].user.name ??
                      'Nombre desconocido'; // Si el nombre es nulo, establece un valor predeterminado
                  return Card(
                    child: ListTile(
                      title: Text(userName),
                      subtitle: Text(postsList[index].text),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCommentDialog(context);
        },
        label: Text(
          'Agregar Comentario',
          style: TextStyle(
              color: Colors.white), // Estilo del texto con color blanco
        ),
        icon: Icon(Icons.add, color: Colors.white), // Color del ícono a blanco
        backgroundColor: Colors.deepOrangeAccent,
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
                TextFormField(
                  textAlign: TextAlign.center,
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: 'Escribe tu respuesta aquí...',
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    String comment = commentController.text;
                    _replyToComment(comment);
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

  Future<void> _replyToComment(String comment) async {
    try {
      Map<String, dynamic> body = {
        "forum": {"id": widget.forumPost.id},
        "text": comment,
        "user": {"id": widget.userLog.id}
      };

      var response = await http.post(
        Uri.parse('http://localhost:3000/post'),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Comentario Añadido');
        }
        _loadComments();
      } else {
        print('Error al añadir foro: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error al añadir foro: $e');
    }
  }
}
