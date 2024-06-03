import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:pets/models/forum.dart';
import 'package:pets/models/post.dart';
import 'package:pets/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:pets/utils/custom_snackbar.dart';

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
        title: Text('Detalles del Post'),
      ),
      backgroundColor: Colors.deepOrange[100],
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
              'Comentarios:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: postsList.length,
                itemBuilder: (context, index) {
                  final userName = postsList[index].user.name ??
                      'Nombre desconocido'; // Si el nombre es nulo, establece un valor predeterminado
                  return Card(
                    child: Column(
                      children: [
                        postsList[index].user.id == widget.userLog.id ? 
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              color: Colors.red,
                              onPressed: () {

                                _deletePost(postsList[index].id);
                               
                              },
                              icon: Icon(Icons.delete),
                            ),
                          ],
                        ) : Container(),
                        ListTile(
                          title: Text(userName),
                          subtitle: Text(postsList[index].text),
                        ),
                        Row(
                        children: [
                          IconButton(
                            icon: postsList[index].likedByUser
                                ? Icon(Icons.favorite, color: Colors.red)
                                : Icon(Icons.favorite_border),
                            onPressed: () {
                              
                              _likePost(postsList[index],  widget.userLog);
                              
                            },
                          ),
                      Text('${widget.forumPost.likes}'),
                    ],
                  ),
                      ],
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
        label: Text('Agregar Comentario'),
        icon: Icon(Icons.add),
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

  Future<void> _likePost(Post post, User user) async {
    if (!post.likedByUser) {
      try {
        var response =
            await http.put(Uri.parse("http://localhost:3000/post/${post.id}/like/${user.id}"));
        if (response.statusCode == 200) {
          // Acción exitosa
          setState(() {

            post.likedByUser = true;

          });
        } else {
          // Manejo de error si la respuesta no es exitosa
          print('Error al dar like: ${response.statusCode}');
        }
      } catch (e) {
        // Manejo de excepción
        print('Excepción al dar like: $e');
      }
    } else {
      try {
        var response =
            await http.put(Uri.parse("http://localhost:3000/post/${post.id}/dislike/${user.id}"));
        if (response.statusCode == 200) {
          // Acción exitosa
          setState(() {
            
           post.likedByUser = false;

          });
        } else {
          // Manejo de error si la respuesta no es exitosa
          print('Error al dar dislike: ${response.statusCode}');
        }
      } catch (e) {
        // Manejo de excepción
        print('Excepción al dar dislike: $e');
      }
    }
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

  Future<void> _deletePost(int int) async {
    try {
      var response = await http.delete(
        Uri.parse('http://localhost:3000/post/$int'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          
          CustomSnackBar.show(context, 'Comentario Borrado', true);

        }
        _loadComments();
      } else {
        print('Error al eliminar post: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error al eliminar post: $e');
    }
  }

}
