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
                    child: Column(
                      children: [
                        postsList[index].user.id == widget.userLog.id
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    color: Colors.red,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title:
                                                Text('Confirmar eliminación'),
                                            content: Text(
                                                '¿Estás seguro de que quieres eliminar este comentario?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Cierra el cuadro de diálogo
                                                },
                                                child: Text('Cancelar'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  // Implementa la lógica para eliminar el comentario del servidor
                                                  _deletePost(
                                                      postsList[index].id);
                                                  Navigator.of(context)
                                                      .pop(); // Cierra el cuadro de diálogo
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor: Colors
                                                      .red, // Color del texto del botón
                                                ),
                                                child: Text('Eliminar'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    icon: Icon(Icons.delete),
                                  ),
                                ],
                              )
                            : Container(),
                        ListTile(
                          title: Text(userName),
                          subtitle: Text(postsList[index].text),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: postsList[index].likedByUser
                                  ? Icon(Icons.favorite, color: Colors.red)
                                  : Icon(Icons.favorite_border),
                              onPressed: () {
                                _likePost(postsList[index], widget.userLog);
                              },
                            ),
                            Text('${widget.forumPost.likes}'),
                            SizedBox(width: 20,)
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
    TextEditingController postController = TextEditingController();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.6, // Altura del 60% de la pantalla
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
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.deepOrange),
                    controller: postController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu respuesta al foro aquí...',
                      hintStyle: TextStyle(color: Colors.deepOrange),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    String post = postController.text;

                    // Implementa la lógica para enviar el comentario al servidor
                    _replyToComment(post);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor:
                        Colors.deepOrange, // Color del texto del botón
                    shadowColor: Colors.deepOrangeAccent, // Color de la sombra
                    elevation: 5, // Elevación del botón
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30.0), // Bordes redondeados
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 12.0), // Espaciado interno
                  ),
                  child: Text(
                    'Enviar',
                    style: TextStyle(
                      fontSize: 16.0, // Tamaño de la fuente del texto del botón
                      fontWeight: FontWeight.bold, // Grosor de la fuente
                    ),
                  ),
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
        var response = await http.put(
            Uri.parse("http://localhost:3000/post/${post.id}/like/${user.id}"));
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
        var response = await http.put(Uri.parse(
            "http://localhost:3000/post/${post.id}/dislike/${user.id}"));
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
