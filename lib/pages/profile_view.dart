import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pets/components/IconTextButton.dart';
import 'package:pets/components/menuRow.dart';
import 'package:pets/pages/Login.dart';
import 'package:pets/utils/TColor.dart';

class ProfileView extends StatelessWidget {
  static String id = "profile_page";
  final GoogleSignInAccount account;

  const ProfileView({
    super.key,
    required this.account,
  });

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
                    backgroundImage: NetworkImage(account.photoUrl ?? 'https://example.com/default-avatar.png'),
                    onBackgroundImageError: (exception, stackTrace) {
                      // Manejar error en la carga de la imagen
                    },
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  Text(
                    account.displayName ?? 'Usuario',
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
                    "Información Usuario",
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
                      child: IconTextButton(
                        icon: Icon(Icons.comment_bank_rounded),
                        title: "Comentarios",
                        subTitle: "",
                        onPressed: () {},
                      ),
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                    Expanded(
                      child: IconTextButton(
                        icon: Icon(Icons.question_answer),
                        title: "Respuestas",
                        subTitle: "",
                        onPressed: () {},
                      ),
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                    Expanded(
                      child: IconTextButton(
                        icon: Icon(Icons.rate_review),
                        title: "Fiabilidad",
                        subTitle: "",
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
                      Login.signOut(context);
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
