import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:pets/models/config.dart';
import 'package:pets/models/user.dart';
import 'package:pets/pages/Login.dart';
import 'package:pets/pages/home.dart';
import 'package:intl/intl.dart';
import 'package:pets/utils/custom_snackbar.dart';

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
          child: SingleChildScrollView(
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
                    height: 130,
                    width: double.infinity,
                  ).animate().flipH(
                      duration: Duration(milliseconds: 400),
                      begin: 0,
                      end: 8,
                      delay: Duration(milliseconds: 100),
                      curve: Curves.elasticInOut),
                  const SizedBox(height: 10.0),
                  _buildTextField("Name", _nameController),
                  const SizedBox(height: 10.0),
                  _buildTextField("Apellidos", _lastNameController),
                  const SizedBox(height: 10.0),
                  _buildTextField("Dirección", _addressController),
                  const SizedBox(height: 10.0),
                  _buildTextField("Código Postal", _postalCodeController),
                  const SizedBox(height: 10.0),
                  _buildDateField("Fecha de Nacimiento", _birthdayController),
                  const SizedBox(height: 10.0),
                  _buildEmailTextField("Email", _emailController),
                  const SizedBox(height: 10.0),
                  _buildPasswordTextField("Contraseña", _passwordController),
                  _buildRegisterButton(),
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(String labelText, TextEditingController controller) {
    return GestureDetector(
      onTap: () async {
        final DateTime now = DateTime.now();
        final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: now,
            firstDate: DateTime(1900),
            lastDate: now, // Únicamente permite seleccionar fechas hasta hoy.
            locale: Locale("es", "ES"));
        if (picked != null) {
          final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
          controller.text = formattedDate;
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.datetime,
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
        ),
      ),
    ).animate().slideX(begin: -1);
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

  Widget _buildEmailTextField(
      String labelText, TextEditingController controller) {
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email_outlined),
        labelText: "Email",
        hintText: "Email@email.com",
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

  Widget _buildPasswordTextField(
      String labelText, TextEditingController controller) {
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
            CustomSnackBar.show(
                context, 'Por favor complete todos los campos.', true);
          } else if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]{3,}$')
              .hasMatch(_nameController.text)) {
            CustomSnackBar.show(
                context,
                'El nombre debe contener solo letras y tener al menos 3 caracteres.',
                true);
          } else if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]{3,}$')
              .hasMatch(_lastNameController.text)) {
            CustomSnackBar.show(
                context,
                'El apellido debe contener solo letras y tener al menos 3 caracteres.',
                true);
          } else if (!RegExp(r'^(?=.*\d)[a-zA-Z0-9À-ÿ\s,.\-]{4,}$')
              .hasMatch(_addressController.text)) {
            CustomSnackBar.show(
                context,
                'La dirección tiene que tener numero y tener al menos 4 caracteres',
                true);
          } else if (!RegExp(r'^\d{5}$').hasMatch(_postalCodeController.text)) {
            CustomSnackBar.show(
                context, 'El Código Postal tiene que tener 5 digitos', true);
          } else if (!RegExp(
                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
              .hasMatch(_emailController.text)) {
            CustomSnackBar.show(context,
                'El formato del email introducido es incorrecto', true);
          } else if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{6,}$')
              .hasMatch(_passwordController.text)) {
            CustomSnackBar.show(
                context,
                'La contraseña debe tener al menos una mayúscula, más de cinco caracteres y al menos un dígito.',
                true);
          } else {
            // Todos los campos están completos y la contraseña cumple con el patrón, proceder con el registro
            registerUser(
              context,
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

  Widget _buildLoginLink() {
    return Container(
      margin: EdgeInsets.only(
          top: 25.0), // Puedes ajustar el valor según lo que necesites
      child: GestureDetector(
        onTap: () {
          // Navegar a la pantalla de registro
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
        child: Text(
          '¿Ya tienes cuenta? Inicia Sesión',
          style: TextStyle(
            color: Colors.deepOrange[300],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> registerUser(
      BuildContext context,
      String email,
      String password,
      String address,
      String birthday,
      String lastName,
      String postalCode,
      String name) async {
    // print(1);
    // print(email);
    // print(2);
    // print(password);
    // print(3);
    // print(address);
    // print(4);
    // print(birthday);
    // print(5);
    // print(postalCode);
    // print(6);
    // print(name);

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
      
      final configString = await rootBundle.loadString('assets/config.json');
      final configJson = json.decode(configString);
      final config = Config.fromJson(configJson);

      var response = await http.post(
        Uri.parse('http://${config.host}:3000/user'),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {

        try {
          
          Map<String, dynamic> userData = jsonDecode(response.body);
          User user = User.fromJson(userData);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => MyHomePage(
                      user: user,
                      activo: false,
                    )),
            (route) => false,
          );

          CustomSnackBar.show(
            context, 'Usuario registrado exitosamente', false);

        } catch (FormatException) {
          CustomSnackBar.show(
            context, 'Este email ya ha sido registrado', true);

        }
      } else {
        CustomSnackBar.show(
            context, 'Error del cliente. Intentelo de nuevo más tarde', true);
      }
    } catch (e) {
      print(e);
      CustomSnackBar.show(
          context, 'Error del servidor. Intentelo de nuevo más tarde', true);
    }
  }
}
