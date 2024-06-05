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
  try {
    final response = await http.get(
      Uri.parse('http://localhost:3000/post/$postId/countLikes'),
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

// Future<bool> fetchLikeStatus(int postId, String userId) async {
//   try {
//     final response = await http.get(
//       Uri.parse('http://localhost:3000/post/$postId//$userId'),
//     );

//     if (response.statusCode == 200) {
//       final bool liked = json.decode(response.body);
//       return liked;
//     } else {
//       throw Exception('Failed to load like status: ${response.reasonPhrase}');
//     }
//   } catch (e) {
//     throw Exception('Failed to load like status: $e');
//   }
// }

class PostDetailsPageState extends State<PostDetailsPage> {
  List<Post> postsList = [];
  Map<int, int> likesMap = {};
  Map<int, bool> likeStatusMap = {};

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

      // Load likes and like status for each post
      for (Post post in posts) {
        _loadLikes(post.id);
        // _loadLikeStatus(post.id, widget.userLog.id);
      }
    } catch (e) {
      print('Error loading comments: $e');
    }
  }

  Future<void> _loadLikes(int postId) async {
    try {
      int likes = await fetchLikesPostsForForum(postId);

      setState(() {
        likesMap[postId] = likes;
      });
    } catch (e) {
      print('Error loading likes: $e');
    }
  }

  // Future<void> _loadLikeStatus(int postId, String userId) async {
  //   try {
  //     bool liked = await fetchLikeStatus(postId, userId);

  //     setState(() {
  //       likeStatusMap[postId] = liked;
  //     });
  //   } catch (e) {
  //     print('Error loading like status: $e');
  //   }
  // }

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
            height: 180,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    Text(
                      widget.forumPost.user.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      widget.forumPost.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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
                final post = postsList[index];
                final userName = post.user.name ?? 'Nombre desconocido';
                final likes = likesMap[post.id] ?? 0;
                final likedByUser = likeStatusMap[post.id] ?? false;

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
                      mouseCursor:MaterialStateMouseCursor.clickable ,
                      
                      // focusColor: Colors.transparent,
                      hoverColor: post.user.id == widget.userLog.id ? Colors.red[100] :Colors.transparent,
                      // splashColor: Colors.transparent,
                      // highlightColor: Colors.transparent,
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
                            title: Text(userName),
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
                                  _likePost(post, widget.userLog);
                                },
                              ),
                              Text('$likes'),
                              SizedBox(
                                width: 20,
                              ),
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
          SizedBox(
            height: 80,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCommentDialog(context);
        },
        label: Text(
          'Agregar Comentario',
          style: TextStyle(color: Colors.white),
        ),
        icon: Icon(Icons.add, color: Colors.white),
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
          heightFactor: 0.6,
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
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: postController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Escribe tu comentario aquí',
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    String post = postController.text;
                    _replyToComment(post);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepOrange,
                    shadowColor: Colors.deepOrangeAccent,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
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
        );
      },
    );
  }

  Future<void> _likePost(Post post, User user) async {
    if (!likeStatusMap[post.id]!) {
      try {
        var response = await http.put(
            Uri.parse("http://localhost:3000/post/${post.id}/like/${user.id}"));
        if (response.statusCode == 200) {
          setState(() {
            likeStatusMap[post.id] = true;
            likesMap[post.id] = (likesMap[post.id] ?? 0) + 1;
          });
        } else {
          print('Error al dar like: ${response.statusCode}');
        }
      } catch (e) {
        print('Excepción al dar like: $e');
      }
    } else {
      try {
        var response = await http.put(Uri.parse(
            "http://localhost:3000/post/${post.id}/dislike/${user.id}"));
        if (response.statusCode == 200) {
          setState(() {
            likeStatusMap[post.id] = false;
            likesMap[post.id] = (likesMap[post.id] ?? 0) - 1;
          });
        } else {
          print('Error al dar dislike: ${response.statusCode}');
        }
      } catch (e) {
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

  Future<void> _deletePost(int postId) async {
    try {
      var response = await http.delete(
        Uri.parse('http://localhost:3000/post/$postId'),
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
