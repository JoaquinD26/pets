import 'package:flutter/material.dart';
import 'package:pets/components/IconTextButton.dart';
import 'package:pets/components/menuRow.dart';
import 'package:pets/models/user.dart';
import 'package:pets/pages/Login.dart';
import 'package:pets/utils/TColor.dart';

class ProfileView extends StatefulWidget {
  static String id = "profile_page";

  late User user; // Agrega un parámetro para recibir el usuario logeado

  ProfileView({required this.user, super.key});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {

  @override
  void initState() {
    super.initState();
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
              onPressed: () {},
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
                    backgroundColor: TColor.secondary,
                    backgroundImage: NetworkImage(widget.user.mainImage ?? ""),
                    onBackgroundImageError: (exception, stackTrace) {
                      // Manejar error en la carga de la imagen
                    },
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  Text(
                    '${widget.user.name} ${widget.user.lastname}',
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
                    widget.user.email,
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
                        icon: Icon(Icons.comment_bank_rounded),
                        title: "Comentarios",
                        subTitle: "200",
                        onPressed: () {},
                      ),
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                    Expanded(
                      flex: 2,
                      child: IconTextButton(
                        icon: Icon(Icons.question_answer),
                        title: "Respuestas",
                        subTitle: "200",
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
                        subTitle: "200",
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
                    onPressed: () {},
                  ),
                  const Divider(
                    color: Colors.black26,
                    height: 1,
                  ),
                  MenuRow(
                    icon: Icon(Icons.comment),
                    title: "Comentarios",
                    onPressed: () {},
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
              
                      Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
                      
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
