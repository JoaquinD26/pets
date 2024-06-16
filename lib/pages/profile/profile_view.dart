import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pets/components/icon_text_button.dart';
import 'package:pets/components/menu_row.dart';
import 'package:pets/models/config.dart';
import 'package:pets/models/user.dart';
import 'package:pets/pages/login.dart';
import 'package:pets/pages/posts_liked.dart';
import 'package:pets/pages/profile/profile_form.dart';
import 'package:pets/utils/t_color.dart';

class ProfileView extends StatefulWidget {
  final String id = "profile_page";
  final User userLog; // Agrega un parámetro para recibir el usuario logeado

  const ProfileView({required this.userLog, super.key});

  @override
  ProfileViewState createState() => ProfileViewState();
}

class ProfileViewState extends State<ProfileView> {
  int countPost = 0;
  int countPostLikes = 0;

  @override
  void initState() {
    super.initState();
    countAllPostLikes();
    countAllPost();
  }


  //Cuenta todos los likes del post del usuario actual
  Future<void> countAllPost() async {
    final configString = await rootBundle.loadString('assets/config.json');
    final configJson = json.decode(configString);
    final config = Config.fromJson(configJson);

    final response = await http.get(
        Uri.parse('http://${config.host}:3000/post/user/${widget.userLog.id}'));
    if (response.statusCode == 200) {
      final posts = json.decode(response.body);
      setState(() {
        countPost = posts.length; // Contar el número de posts
      });
    } else {
      // Manejar error en la solicitud
      print('Failed to load posts count');
    }
  }

  Future<void> countAllPostLikes() async {
    final configString = await rootBundle.loadString('assets/config.json');
    final configJson = json.decode(configString);
    final config = Config.fromJson(configJson);

    final response = await http.get(
        Uri.parse('http://${config.host}:3000/post/user/${widget.userLog.id}'));
    if (response.statusCode == 200) {
      final posts = json.decode(response.body);
      int totalLikes = 0;

      for (var post in posts) {
        final postId = post['id'];
        final likesResponse = await http.get(
            Uri.parse('http://${config.host}:3000/post/$postId/countLikes'));

        if (likesResponse.statusCode == 200) {
          final likesCount = json.decode(likesResponse.body);
          totalLikes += (likesCount as int); // Casting a int
        } else {
          // Manejar error en la solicitud de likes
          print('Failed to load likes count for post $postId');
        }
      }

      setState(() {
        countPostLikes = totalLikes; // Suma total de likes de todos los posts
      });
    } else {
      // Manejar error en la solicitud de posts
      print('Failed to load posts');
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileForm(
                            user: widget.userLog,
                          )),
                );
              },
              child: Text(
                "Editar Perfil",
                style: TextStyle(
                  color: TColor.primary,
                  fontSize: 16,
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: media.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 1)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: media.width * 0.125,
                    backgroundImage: NetworkImage(
                        "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png"),
                    onBackgroundImageError: (exception, stackTrace) {
                      // Manejar error en la carga de la imagen
                    },
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  Text(
                    '${widget.userLog.name} ${widget.userLog.lastname}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TColor.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(
                    height: media.width * 0.025,
                  ),
                  Text(
                    widget.userLog.email,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(
                    height: media.width * 0.1,
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 1)],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: IconTextButton(
                        icon: Icon(Icons.question_answer),
                        title: "Posts",
                        subTitle: countPost.toString(),
                        onPressed: () {},
                      ),
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                    Expanded(
                      flex: 2,
                      child: IconTextButton(
                        icon: Icon(Icons.rate_review),
                        title: "Fiabilidad",
                        subTitle: countPostLikes.toString(),
                        onPressed: () {},
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 1)],
              ),
              child: Column(
                children: [
                  MenuRow(
                    icon: Icon(Icons.favorite),
                    title: "Me gustas",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostsLikedPage(
                            userLog: widget.userLog,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    color: Colors.black26,
                    height: 1,
                  ),
                  MenuRow(
                    icon: Icon(Icons.logout_outlined),
                    title: "Cerrar Sesión",
                    onPressed: () async {
                      // Realizar el cierre de sesión
                      Navigator.pushNamedAndRemoveUntil(
                          context, LoginPage.id, (route) => false);
                    },
                  ),
                  const Divider(
                    color: Colors.black26,
                    height: 1,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
