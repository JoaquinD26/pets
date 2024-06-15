import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pets/models/config.dart';
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

Future<Config> loadConfig() async {
  final configString = await rootBundle.loadString('assets/config.json');
  final configJson = json.decode(configString);
  return Config.fromJson(configJson);
}

Future<List<Post>> fetchPostsForForum(int forumId) async {
  final config = await loadConfig();
  try {
    final response = await http.get(
      Uri.parse('http://${config.host}:3000/post/forum/$forumId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
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

Future<int> fetchLikesPostsForForum(int postId) async {
  final config = await loadConfig();
  try {
    final response = await http.get(
      Uri.parse('http://${config.host}:3000/post/$postId/countLikes'),
    );

    if (response.statusCode == 200) {
      final int likes = json.decode(response.body);
      return likes;
    } else {
      throw Exception('Failed to load likes: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Failed to load likes: $e');
  }
}

Future<bool> fetchLikeStatus(int postId, String userId) async {
  final config = await loadConfig();
  try {
    final response = await http.get(
      Uri.parse('http://${config.host}:3000/post/$postId/like/$userId'),
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);

      if (responseData['data'] == null) {
        return false;
      } else {
        return true;
      }
    } else {
      throw Exception('Failed to load like status: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Failed to load like status: $e');
  }
}

class PostDetailsPageState extends State<PostDetailsPage> {
  List<Post> postsList = [];
  Map<int, int> likesMap = {};
  Map<int, bool> likedByUserMap = {};

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

      // Cargar likes y estado de like para cada post
      for (var post in posts) {
        _loadLikes(post.id);
        _loadStatusLike(post.id, widget.userLog.id);
      }
    } catch (e) {
      print('Error loading comments: $e');
    }
  }

  Future<void> _loadLikes(int postId) async {
    try {
      int totalLikes = await fetchLikesPostsForForum(postId);

      setState(() {
        likesMap[postId] = totalLikes;
      });
    } catch (e) {
      print('Error loading likes: $e');
    }
  }

  Future<void> _loadStatusLike(int postId, String userId) async {
    try {
      bool isLiked = await fetchLikeStatus(postId, userId);

      setState(() {
        likedByUserMap[postId] = isLiked;
      });
    } catch (e) {
      print('Error loading likes: $e');
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 240,
            margin: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Card(
              color: Colors.white,
              margin: EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(
                                  "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png")),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.forumPost.user.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                widget.forumPost.date
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
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
            ),
          ),
          Center(child: Text("Respuestas")),
          Expanded(
            child: ListView.builder(
              itemCount: postsList.length,
              itemBuilder: (context, index) {
                final post = postsList[index];
                final userName = post.user.name ?? 'Nombre desconocido';

                final likes = likesMap[post.id] ?? 0;
                final likedByUser = likedByUserMap[post.id] ?? false;

                return Container(
                  margin: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 0,
                    child: InkWell(
                      mouseCursor: MaterialStateMouseCursor.clickable,
                      hoverColor: post.user.id == widget.userLog.id
                          ? Colors.red[100]
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      onLongPress: () {
                        post.user.id == widget.userLog.id
                            ? showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Confirmar eliminación'),
                                    content: Text(
                                        '¿Estás seguro de que quieres eliminar este comentario?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          _deletePost(post.id);
                                          Navigator.of(context).pop();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.red,
                                        ),
                                        child: Text('Eliminar'),
                                      ),
                                    ],
                                  );
                                },
                              )
                            : Container();
                      },
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              userName,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(post.text),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: likedByUser
                                    ? Icon(Icons.favorite, color: Colors.red)
                                    : Icon(Icons.favorite_border),
                                onPressed: () {
                                  _toggleLikePost(post, widget.userLog);
                                },
                              ),
                              Text('$likes'),
                              SizedBox(
                                width: 20,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCommentDialog(context);
        },
        backgroundColor: Colors.orange,
        child: Icon(color: Colors.white, Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showCommentDialog(BuildContext context) {
    TextEditingController postController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        // Variable para mantener el nodo de enfoque del campo de texto
        FocusNode commentFocusNode = FocusNode();

        // Enfoca automáticamente el campo de texto una vez que el modal se ha construido
        WidgetsBinding.instance.addPostFrameCallback((_) {
          commentFocusNode.requestFocus();
        });

        return GestureDetector(
          onTap: () {
            // Cierra el teclado y desenfoca el campo de texto al tocar fuera
            FocusScope.of(context).unfocus();
          },
          child: FractionallySizedBox(
            heightFactor: 0.7,
            alignment: Alignment.topCenter,
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
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.0),
                  Form(
                    key: _formKey,
                    child: Focus(
                      focusNode: commentFocusNode,
                      child: TextFormField(
                        controller: postController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Escribe tu comentario aquí',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Escriba su comentario antes de enviar";
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        String post = postController.text;
                        // Lógica para enviar el comentario
                        _replyToComment(post);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepOrange,
                      shadowColor: Colors.deepOrangeAccent,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 12.0),
                    ),
                    child: Text(
                      'Enviar',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleLikePost(Post post, User user) async {
    final config = await loadConfig();

    // Verificar el estado actual del like
    bool isLiked = likedByUserMap[post.id] ?? false;

    String accion = '';

    isLiked ? accion = "dislike" : accion = "like";

    try {
      var response = await http.put(
        Uri.parse(
          "http://${config.host}:3000/post/${post.id}/${accion}/${user.id}",
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          likedByUserMap[post.id] = !isLiked; // Alternar el estado del like
          likesMap[post.id] = (likesMap[post.id] ?? 0) +
              (isLiked ? -1 : 1); // Ajustar el conteo de likes
        });
      } else {
        print(
            'Error al ${isLiked ? 'quitar' : 'dar'} like: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al ${isLiked ? 'quitar' : 'dar'} like: $e');
    }
  }

  Future<void> _replyToComment(String comment) async {
    final config = await loadConfig();
    try {
      Map<String, dynamic> body = {
        "forum": {"id": widget.forumPost.id},
        "text": comment,
        "user": {"id": widget.userLog.id}
      };

      var response = await http.post(
        Uri.parse('http://${config.host}:3000/post'),
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

  Future<void> _deletePost(int postId) async {
    final config = await loadConfig();

    try {
      var response = await http.delete(
        Uri.parse('http://${config.host}:3000/post/$postId'),
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
