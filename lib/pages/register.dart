import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:pets/models/user.dart';
import 'package:pets/pages/home.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Registro de Usuario',
                  style: TextStyle(
                    fontFamily: 'Comfortaa',
                    color: Colors.orange,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0),
                Image.asset(
                  "icon/icon.png",
                  height: 150,
                  width: double.infinity,
                ).animate().flipH(
                    duration: Duration(milliseconds: 400),
                    begin: 0,
                    end: 8,
                    delay: Duration(milliseconds: 100),
                    curve: Curves.elasticInOut),
                const SizedBox(height: 15.0),
                _buildTextField("Name", _nameController),
                const SizedBox(height: 15.0),
                _buildTextField("Apellidos", _lastNameController),
                const SizedBox(height: 15.0),
                _buildTextField("Dirección", _addressController),
                const SizedBox(height: 15.0),
                _buildTextField("Código Postal", _postalCodeController),
                const SizedBox(height: 15.0),
                _buildTextField("Fecha de Nacimiento", _birthdayController),
                const SizedBox(height: 15.0),
                _buildEmailTextField("Email", _emailController),
                const SizedBox(height: 15.0),
                _buildPasswordTextField("Contraseña", _passwordController),
                _buildRegisterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: labelText,
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

  Widget _buildEmailTextField(String labelText, TextEditingController controller) {
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email_outlined),
        labelText: "Email",
        hintText: "Joaquindiazlidon@gmail.com",
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

  Widget _buildPasswordTextField(String labelText, TextEditingController controller) {
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
    ).animate().slideX(begin: -1);
  }


  Widget _buildRegisterButton() {
    return Container(
      margin: EdgeInsets.only(top: 20.0), // Ajusta el valor según sea necesario
      child: ElevatedButton(
        onPressed: () {
          // Verificar que todos los campos estén completos
          if (_emailController.text.isEmpty ||
              _passwordController.text.isEmpty ||
              _addressController.text.isEmpty ||
              _birthdayController.text.isEmpty ||
              _lastNameController.text.isEmpty ||
              _postalCodeController.text.isEmpty ||
              _nameController.text.isEmpty) {
            // Mostrar un diálogo o un mensaje de error si algún campo está vacío
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Error'),
                content: Text('Por favor complete todos los campos.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          } else if (!RegExp(r'^[a-zA-ZÀ-ÿ]{3,}$').hasMatch(_nameController.text)) {
            // Mostrar un mensaje de error si el nombre o los apellidos contienen caracteres que no son letras
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Error'),
                content: Text('El nombre debe contener solo letras y tener al menos 3 caracteres.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          }else if (!RegExp(r'^[a-zA-ZÀ-ÿ]{3,}$').hasMatch(_lastNameController.text)) {
            // Mostrar un mensaje de error si el nombre o los apellidos contienen caracteres que no son letras
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Error'),
                content: Text('El apellido debe contener solo letras y tener al menos 3 caracteres.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          }
          else if (!RegExp(r'^(?=.*\d)[a-zA-Z0-9À-ÿ\s,.\-]{4,}$').hasMatch(_addressController.text)) {
            // Mostrar un mensaje de error si el nombre o los apellidos contienen caracteres que no son letras
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Error'),
                content: Text('La dirección tiene que tener numero y tener al menos 4 caracteres'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          }
          else if (!RegExp(r'^\d{5}$').hasMatch(_postalCodeController.text)) {
            // Mostrar un mensaje de error si el nombre o los apellidos contienen caracteres que no son letras
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Error'),
                content: Text('El Código Postal tiene que tener 5 digitos'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          }
          else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(_emailController.text)) {
            // Mostrar un mensaje de error si el nombre o los apellidos contienen caracteres que no son letras
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Error'),
                content: Text('El formato del email introducido es incorrecto'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          }
          else if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{6,}$').hasMatch(_passwordController.text)) {
            // Mostrar un mensaje de error si el nombre o los apellidos contienen caracteres que no son letras
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Error'),
                content: Text('La contraseña debe tener al menos una mayúscula, más de cinco caracteres y al menos un dígito.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          }
          else {
                    
            // Todos los campos están completos y la contraseña cumple con el patrón, proceder con el registro
            registerUser(
              _emailController.text,
              _passwordController.text,
              _addressController.text,
              _birthdayController.text,
              _lastNameController.text,
              _postalCodeController.text,
              _nameController.text,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: Text(
          "Registrarse",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }


  Future<void> registerUser(String email, String password, String address,
      String birthday, String lastName, String postalCode, String name) async {
    try {
      Map<String, dynamic> body = {
        'email': email,
        'name': name,
        'password': password,
        'address': address,
        'birthday': birthday,
        'lastName': lastName,
        'postalCode': postalCode,
      };

      var response = await http.post(
        Uri.parse('http://localhost:3000/user'),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = jsonDecode(response.body);
        User user = User.fromJson(userData);

        if (kDebugMode) {
          print('Usuario registrado exitosamente');
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage(user: user)),
          (route) => false,
        );
      } else {
        print('Error al registrar usuario: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error al registrar usuario: $e');
    }
  }
}