import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:pets/pages/Home.dart';

class LoginPage extends StatefulWidget {
  static String id = "login_page";

  const LoginPage({super.key});

  @override
  Login createState() => Login();
}

class Login extends State<LoginPage> {
  late String email;
  late String password;

  final _email = TextEditingController();
  final _password = TextEditingController();

  // Future<dynamic> signIn() async {
  //   email = _email.text;
  //   password = _password.text;

  //   String ipCasa = '192.168.1.21';
  //   String ipCamp = '192.168.202.27';

  //   try {
  //     Map<dynamic, dynamic> params = {
  //       "action": "login",
  //       'user': '{"email": "$email","password": "$password"}',
  //     };

  //     var url = Uri.parse('http://$ipCasa/gestionhotelera/sw_user.php');
  //     // var url = Uri.parse('http://$ipCamp/gestionhotelera/sw_user.php');

  //     var response = await http.post(url, body: params);

  //     if (response.statusCode == 200) {
  //       final jsonResponse = jsonDecode(response.body);
  //       if (jsonResponse['success'] == true) {
  //         // ignore: use_build_context_synchronously
  //         Navigator.push(
  //           context,
  //           PageRouteBuilder(
  //             pageBuilder: (context, animation, secondaryAnimation) =>
  //                 const MyHomePage(account1: null,),
  //             transitionsBuilder:
  //                 (context, animation, secondaryAnimation, child) {
  //               var begin = 0.0;
  //               var end = 1.3;
  //               var curve = Curves.ease;

  //               var tween = Tween(begin: begin, end: end)
  //                   .chain(CurveTween(curve: curve));

  //               return FadeTransition(
  //                 opacity: animation.drive(tween),
  //                 child: child,
  //               );
  //             },
  //           ),
  //         );
  //       } else {
  //         // Maneja el caso en que la autenticación falla
  //         print('Error de autenticación');
  //       }
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        _currentUser = account;
      });
      if (account != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage(account1: _currentUser,)),
        );
      }
    });
    _googleSignIn.signInSilently();
    super.initState();
  }

   static void signOut(BuildContext context) {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    _googleSignIn.disconnect().then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  // Future<void> signInGoogle() async {
  //   try {
  //     GoogleSignInAccount? account = await _googleSignIn.signIn();
  //     if (account != null) {
  //       // Navega a la página principal si la autenticación es exitosa
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => MyHomePage(account1: _currentUser,)),
  //       );


  //     }
  //   } catch (e) {
  //     print('Error de Inicio de Sesión: $e');
  //   }
  // }


  Future<void> signInGoogle() async {
  try {
    GoogleSignInAccount? account = await _googleSignIn.signIn();
    if (account != null) {
      // Si la autenticación es exitosa, obtén la ID del usuario
      String nombreG = account.displayName!;

      // Llama al método que realiza la solicitud POST con la ID del usuario
      await sendUserIdToServer(nombreG);
      
      // Navega a la página principal si la autenticación es exitosa
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage(account1: _currentUser)),
      );
    }
  } catch (e) {
    print('Error de Inicio de Sesión: $e');
  }
}

Future<void> sendUserIdToServer(String nombreG) async {
  try {
    // Construye el cuerpo de la solicitud con la ID del usuario
    Map<String, dynamic> body = {'nombre': nombreG};
    
    // Realiza la solicitud POST al servidor
    var response = await http.post(
      Uri.parse('http://localhost/pruebaApiPets/usuario.php'),
      body: body,
    );

    // Verifica si la solicitud fue exitosa
    if (response.statusCode == 200) {
      print('ID del usuario enviada al servidor correctamente.');
    } else {
      print('Error al enviar ID del usuario al servidor: ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Error al enviar ID del usuario al servidor: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Pets",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Comfortaa',
                    color: Colors.blueAccent,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Text(
                    'Inicio de Sesión',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      color: Colors.blueAccent,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25.0,
              ),
              _textFieldEmail(),
              const SizedBox(
                height: 25.0,
              ),
              _textFieldPass(),
              const SizedBox(
                height: 25.0,
              ),
              _elevateButton(),
              const SizedBox(
                height: 25.0,
              ),
              _elevateButtonGoogle(),
              const SizedBox(
                height: 25.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _elevateButton() {
    return Container(
      child: ElevatedButton(
        onPressed: () {
          // signIn();
        },
        child: const Text("Iniciar Sesión"),
      ),
    );
  }

  Widget _elevateButtonGoogle() {
    return Container(
      child: ElevatedButton(
        onPressed: () {
          signInGoogle();
        },
        child: const Text('Iniciar sesión con Google'),
      ),
    );
  }

  Widget _textFieldEmail() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 40.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _email,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.email_outlined),
          labelText: "Email",
          hintText: "Joaquindiazlidon@gmail.com",
        ),
        onChanged: (value) {},
      ),
    );
  }

  Widget _textFieldPass() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 40.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _password,
        obscureText: true,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.password_outlined),
          labelText: "Password",
        ),
        onChanged: (value) {},
      ),
    );
  }
}
