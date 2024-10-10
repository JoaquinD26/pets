import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:pets/models/config.dart';
import 'package:pets/models/user.dart';
import 'package:pets/pages/home.dart';
import 'package:pets/pages/register.dart';
import 'package:pets/utils/custom_snackbar.dart';

class LoginPage extends StatefulWidget {
  static String id = "login_page";

  const LoginPage({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Pets",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.deepOrange[400],
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Image.asset(
                    "assets/icon/icon.png",
                    height: 150,
                    width: double.infinity,
                  ).animate().flipH(
                      duration: Duration(milliseconds: 400),
                      begin: 0,
                      end: 8,
                      delay: Duration(milliseconds: 100),
                      curve: Curves.elasticInOut),
                  const SizedBox(height: 25.0),
                  _buildEmailTextField(),
                  const SizedBox(height: 25.0),
                  _buildPasswordTextField(),
                  const SizedBox(height: 25.0),
                  _buildLoginButton(),
                  const SizedBox(height: 25.0),
                  _buildRegisterLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailTextField() {
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email_outlined),
        labelText: "Email",
        hintText: "usuario@gmail.com",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.orange),
        ),
      ),
    ).animate().slideX(begin: -1);
  }

  Widget _buildPasswordTextField() {
    return TextField(
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.password_outlined),
        labelText: "Password",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.orange),
        ),
      ),
    ).animate().slideX(begin: 1);
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () {
        signIn(_emailController.text, _passwordController.text);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrange[400],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Text(
        "Iniciar Sesión",
        style: TextStyle(color: Colors.white),
      ),
    ).animate().slideY(begin: 10, duration: Duration(milliseconds: 370));
  }

  Widget _buildRegisterLink() {
    return GestureDetector(
      onTap: () {
        // Navegar a la pantalla de registro
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegisterPage()),
        );
      },
      child: Text(
        '¿No tienes una cuenta? Regístrate',
        style: TextStyle(
          color: Colors.deepOrange[300],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> signIn(String email, String password) async {

   final configString = await rootBundle.loadString('assets/config.json');
   final configJson = json.decode(configString);
   final config = Config.fromJson(configJson);

    try {
      // Construir el cuerpo de la solicitud
      Map<String, dynamic> body = {
        'email': email,
        'password': password,
      };

      // Realizar la solicitud POST al servidor
      var response = await http.post(
        Uri.parse('http://${config.host}:4000/user/login'),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      var responseBody = jsonDecode(response.body);

      // Verificar si la solicitud fue exitosa
      if (response.statusCode == 200 && responseBody['id'] != null) {
        // Usuario autenticado exitosamente

        // Decodificar la respuesta JSON y crear una instancia de User
        Map<String, dynamic> userData = jsonDecode(response.body);
        User user = User.fromJson(userData);

        // Navegar a la página principal pasando el usuario como argumento
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage(user: user,activo: false,rating: false,)),
            (route) => false);
        // Aquí puedes navegar a la pantalla principal o realizar otras acciones
      } else {
        CustomSnackBar.show(context, "Usuario no encontrado", true);
      }
    } catch (e) {
      print('Error al iniciar sesión: $e');
    }
  }
}
