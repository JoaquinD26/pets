import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:pets/models/config.dart';
import 'package:pets/models/user.dart';
import 'package:pets/pages/Home.dart';
import 'package:pets/pages/profile/profile_view.dart';
import 'package:pets/utils/custom_snackbar.dart';

class ProfileForm extends StatefulWidget {
  final User user;

  const ProfileForm({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<ProfileForm> {
  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  late TextEditingController _addressController;
  late TextEditingController controller;
  late TextEditingController _postalCodeController;
  File? _image;
  Uint8List? _webImage; // For web
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name ?? '');
    _lastNameController =
        TextEditingController(text: widget.user.lastname ?? '');
    _addressController = TextEditingController(text: widget.user.address ?? '');
    controller = TextEditingController(text: widget.user.birthday ?? '');
    _postalCodeController =
        TextEditingController(text: widget.user.cp.toString());
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      // For web
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _webImage = result.files.single.bytes;
        });
      }
    } else {
      // For mobile
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      } else {
        print('No image selected.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Editar Perfil',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.deepOrange[300],
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10.0),
                  _buildTextField("Nombre", _nameController),
                  const SizedBox(height: 10.0),
                  _buildTextField("Apellidos", _lastNameController),
                  const SizedBox(height: 10.0),
                  _buildTextField("Dirección", _addressController),
                  const SizedBox(height: 10.0),
                  _buildTextField("Código Postal", _postalCodeController),
                  const SizedBox(height: 10.0),
                  _buildDateField("Fecha de Nacimiento", controller),
                  const SizedBox(height: 10.0),
                  _buildImagePicker(),
                  const SizedBox(height: 10.0),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        if (_webImage != null)
          Image.memory(_webImage!, height: 200)
        else if (_image != null)
          Image.file(_image!, height: 200)
        else
          Text("No se ha seleccionado ninguna imagen."),
        ElevatedButton(
          onPressed: _pickImage,
          child: Text("Seleccionar Imagen"),
        ),
      ],
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
          locale: Locale("es", "ES"),
        );
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

  Widget _buildSaveButton() {
    return Container(
      margin: EdgeInsets.only(top: 20.0), // Ajusta el valor según sea necesario
      child: ElevatedButton(
        onPressed: () async {
          // Verificar que todos los campos estén completos
          if (_nameController.text.isEmpty ||
              _lastNameController.text.isEmpty ||
              _addressController.text.isEmpty ||
              controller.text.isEmpty ||
              _postalCodeController.text.isEmpty) {
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
          } else {
            String? base64Image;
            if (_image != null) {
              final bytes = await _image!.readAsBytes();
              base64Image = base64Encode(bytes);
            } else if (_webImage != null) {
              base64Image = base64Encode(_webImage!);
            }
            // Todos los campos están completos y la información cumple con el patrón, proceder con la actualización
            updateUser(
                widget.user.id,
                widget.user.email,
                _nameController.text,
                _lastNameController.text,
                _addressController.text,
                controller.text,
                _postalCodeController.text,
                base64Image);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: Text(
          "Guardar",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> updateUser(
      String userId,
      String email,
      String name,
      String lastName,
      String address,
      String birthday,
      String postalCode,
      String? base64Image) async {
    try {
      Map<String, dynamic> body = {
        'name': name,
        'email': email,
        'address': address,
        'birthday': birthday,
        'lastName': lastName,
        'postalCode': postalCode,
        'imgUser': base64Image
      };

      if (base64Image != null) {
        body['imgUser'] = base64Image;
      }

      final configString = await rootBundle.loadString('assets/config.json');
      final configJson = json.decode(configString);
      final config = Config.fromJson(configJson);

      var response = await http.put(
        Uri.parse('http://${config.host}:3000/user/$userId'),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = jsonDecode(response.body);
        User updatedUser = User.fromJson(userData);

        CustomSnackBar.show(context, 'Usuario actualizado exitosamente', false);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => MyHomePage(
                    user: updatedUser,
                    activo: true,
                  )),
          (route) => false,
        );
      } else {
        CustomSnackBar.show(
            context, 'Error al actualizar usuario. Intentelo de nuevo', true);
      }
    } catch (e) {
      CustomSnackBar.show(
          context, 'Error al actualizar usuario. Intentelo de nuevo', true);
    }
  }
}
