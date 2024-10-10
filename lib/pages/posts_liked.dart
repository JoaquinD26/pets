import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pets/models/config.dart';
import 'package:pets/models/post.dart';
import 'package:pets/models/user.dart';
import 'package:pets/utils/custom_snackbar.dart';

class PostsLikedPage extends StatefulWidget {
  final User userLog;

  PostsLikedPage({Key? key, required this.userLog}) : super(key: key);

  @override
  _PostsLikedPageState createState() => _PostsLikedPageState();
}

class _PostsLikedPageState extends State<PostsLikedPage> {
  List<Post> postsList = [];
  Map<int, int> likesMap = {};
  Map<int, bool> likedByUserMap = {};
  TextEditingController replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLikedPosts();
  }

  Future<void> _loadLikedPosts() async {
    try {
      List<Post> posts = await fetchLikedPostsForUser(widget.userLog.id);
      setState(() {
        postsList = posts;
      });

      // Cargar likes y estado de like para cada post
      for (var post in postsList) {
        await _loadLikes(post.id);
        await _loadStatusLike(post.id, widget.userLog.id);
      }
    } catch (e) {
      print('Error loading liked posts: $e');
    }
  }

  Future<List<Post>> fetchLikedPostsForUser(String userId) async {
    final config = await loadConfig();
    try {
      final response = await http.get(
        Uri.parse('http://${config.host}:4000/user/$userId/likedPosts'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        List<Post> posts =
            responseData.map((data) => Post.fromJson(data)).toList();
        return posts;
      } else {
        throw Exception(
            'Failed to load liked posts for user: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to load liked posts for user: $e');
    }
  }

  Future<void> _loadLikes(int postId) async {
    try {
      int likes = await fetchLikesPostsForForum(postId);
      setState(() {
        likesMap[postId] = likes;
      });
    } catch (e) {
      print('Error loading likes for post $postId: $e');
    }
  }

  Future<int> fetchLikesPostsForForum(int postId) async {
    final config = await loadConfig();
    try {
      final response = await http.get(
        Uri.parse('http://${config.host}:4000/post/$postId/countLikes'),
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

  Future<void> _loadStatusLike(int postId, String userId) async {
    try {
      bool liked = await fetchLikeStatus(postId, userId.toString());
      setState(() {
        likedByUserMap[postId] = liked;
      });
    } catch (e) {
      print('Error loading like status for post $postId: $e');
    }
  }

  Future<bool> fetchLikeStatus(int postId, String userId) async {
    final config = await loadConfig();
    try {
      final response = await http.get(
        Uri.parse('http://${config.host}:4000/post/$postId/like/$userId'),
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        return responseData['data'] != null;
      } else {
        throw Exception('Failed to load like status: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to load like status: $e');
    }
  }

  Future<void> _toggleLikePost(Post post) async {
    final config = await loadConfig();
    bool isLiked = likedByUserMap[post.id] ?? false;

    try {
      var response = await http.put(
        Uri.parse(
            "http://${config.host}:4000/post/${post.id}/${isLiked ? 'dislike' : 'like'}/${widget.userLog.id}"),
      );

      if (response.statusCode == 200) {
        setState(() {
          likedByUserMap[post.id] = !isLiked;
          likesMap[post.id] = (likesMap[post.id] ?? 0) + (isLiked ? -1 : 1);
        });
      } else {
        print(
            'Error al ${isLiked ? 'quitar' : 'dar'} like: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al ${isLiked ? 'quitar' : 'dar'} like: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Posts que te gustan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepOrange[300],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: postsList.length,
              itemBuilder: (context, index) {
                final post = postsList[index];
                final userName = post.user.name ?? 'Unknown';

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
                                  _toggleLikePost(post);
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
        ],
      ),
    );
  }

  Future<void> _deletePost(int postId) async {
    final config = await loadConfig();

    try {
      var response = await http.delete(
        Uri.parse('http://${config.host}:4000/post/$postId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        CustomSnackBar.show(context, 'Comentario Borrado', true);
        _loadLikedPosts();
      } else {
        print('Error al eliminar post: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error al eliminar post: $e');
    }
  }

  Future<Config> loadConfig() async {
    final configString = await rootBundle.loadString('assets/config.json');
    final configJson = json.decode(configString);
    return Config.fromJson(configJson);
  }
}
