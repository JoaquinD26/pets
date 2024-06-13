import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:pets/models/config.dart';
import 'package:pets/models/pet.dart';
import 'package:http/http.dart' as http;
import 'package:pets/models/user.dart';
import 'package:pets/pages/home.dart';
import 'package:pets/utils/custom_snackbar.dart';

class AddPetForm extends StatefulWidget {
  final User user;
  final Pet? pet; // Objeto Pet para editar
  final bool isEditing; // Indicador de edición

  const AddPetForm({
    required this.user,
    this.pet, // Pet es opcional para la edición
    this.isEditing = false, // Por defecto no está editando
    super.key,
  });

  @override
  AddPetFormState createState() => AddPetFormState();
}

class AddPetFormState extends State<AddPetForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _animalController = TextEditingController();
  final TextEditingController _raceController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedAnimal = "Perro";
  bool _hasChip = false;
  Uint8List? _selectedImageBytes;
  String? _selectedImagePath;

  Future<Config> loadConfig() async {
    final configString = await rootBundle.loadString('assets/config.json');
    final configJson = json.decode(configString);
    return Config.fromJson(configJson);
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedImageBytes = result.files.single.bytes;
        // _selectedImagePath = result.files.single.path;  // Guardamos la ruta del archivo
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.pet != null) {
      // Inicializar los controladores con los datos del objeto Pet
      _nameController.text = widget.pet!.name;
      _selectedAnimal = widget.pet!.animal == "Perro" ? 'Perro' : 'Gato';
      _raceController.text = widget.pet!.race;
      _weightController.text = widget.pet!.weight.toString();
      _selectedGender = widget.pet!.gender == 1 ? 'Male' : 'Female';

      _hasChip = widget.pet!.chip == 1 ? true : false;
      // Puedes inicializar _selectedImageBytes con la imagen de la mascota si la tienes disponible
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Mascota' : 'Añadir Mascota'),
        backgroundColor: Colors.deepOrange[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    CustomSnackBar.show(context, 'Please enter the name', true);
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedAnimal,
                decoration: InputDecoration(
                  labelText: 'Animal',
                  border: OutlineInputBorder(),
                ),
                items: ['Perro', 'Gato']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAnimal = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _raceController,
                decoration: InputDecoration(
                  labelText: 'Race',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the race';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Weight',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(
                      r'^\d*\.?\d{0,2}')), // Solo permite números y máximo 2 decimales
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    CustomSnackBar.show(
                        context, 'Please enter the weight', true);
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                items: ['Male', 'Female']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text('Has Chip'),
                  Checkbox(
                    value: _hasChip,
                    onChanged: (bool? value) {
                     
                      setState(() {
                        _hasChip = value!;
                        print(_hasChip);
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              _selectedImageBytes == null
                  ? Text('No image selected.')
                  : Image.memory(_selectedImageBytes!),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick an image',
                    style: TextStyle(color: Colors.black)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Crear una nueva mascota
                    Pet pet = Pet(
                      id: !widget.isEditing ? 0 : widget.pet!.id,
                      name: _nameController.text,
                      animal: _selectedAnimal,
                      race: _raceController.text,
                      weight: double.parse(_weightController.text),
                      gender: _selectedGender == 'Male' ? 1 : 0,
                      chip: _hasChip ? 1 : 0,
                      petImg: '', // Manejo de subida de imagen no cubierto
                      eventos: [], // Eventos no incluidos
                    );

                    try {
                      // Añadir la mascota y conectar con el usuario
                      !widget.isEditing
                          ? await _addPetAndConnect(pet)
                          : await _editPet(pet);

                      // Opcionalmente, limpiar el formulario
                      // _formKey.currentState!.reset();
                      // setState(() {
                      //   _selectedGender = 'Male';
                      //   _hasChip = false;
                      //   _selectedImageBytes = null;
                      // });
                    } catch (e) {
                      // Manejar errores y mostrar mensaje de error
                      CustomSnackBar.show(
                          context, "Error al añadir la mascota", true);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange[300],
                ),
                child: Text(
                  !widget.isEditing ? 'Add Pet' : 'Edit Pet',
                  style: TextStyle(color: Colors.black),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<int> _addPet(Pet pet) async {

    final config = await loadConfig();

    try {
      // URL de tu endpoint para agregar mascotas
      final addPetUrl = Uri.parse('http://${config.host}:3000/pet');

      // Convertir el objeto Pet a JSON
      final petJson = pet.toJson();

      // Realizar la solicitud POST para agregar la mascota
      final response = await http.post(
        addPetUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(petJson),
      );

      // Verificar si la solicitud fue exitosa (código de respuesta 200)
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);

        // Añadir prints para depuración
        print('Response body: $responseBody');

        int petId = responseBody['id'];

        uploadPetImage(petId);

        if (kDebugMode) {
          print('Pet ID: $petId');
        }
        return petId;
      } else {
        // Si la solicitud no fue exitosa, imprimir el código de respuesta
        print('Error adding pet. Status code: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      // Manejar cualquier error que ocurra durante la solicitud
      print('Error adding pet: $e');
      return 0;
    }
  }

  Future<void> uploadPetImage(int petId) async {
    final config = await loadConfig();
    if (_selectedImagePath != null) {
      var request = http.MultipartRequest(
          "POST", Uri.parse("http://${config.host}:3000/pet/upload"));
      request.files
          .add(await http.MultipartFile.fromPath('file', _selectedImagePath!));

      String petIdString = petId.toString();
      request.fields['id'] = petIdString;

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Image uploaded successfully');
      } else {
        print('Image upload failed with status: ${response.statusCode}');
      }
    } else {
      print('No image selected');
    }
  }

  Future<void> _connectPetToUser(String userId, int petId) async {

    String userIdStr = userId.toString();
    String petIdStr = petId.toString();

    final config = await loadConfig();

    try {
      // URL de tu endpoint para agregar conexión a mascotas con el usuario actual
      final addPetToUserUrl =
          Uri.parse('http://${config.host}:3000/user/$userIdStr/$petIdStr');

      // Realizar la solicitud POST para conectar la mascota con el usuario
      final response = await http.get(
        addPetToUserUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      // Verificar si la solicitud fue exitosa
      if (response.statusCode == 200) {
        // Mostrar un mensaje de éxito
        CustomSnackBar.show(context, "Mascota añadida correctamente", false);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => MyHomePage(
                    user: widget.user,
                    activo: false,
                    rating: false,
                  )),
          (route) => false,
        );
      } else {
        print(
            'Error connecting pet to user. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Manejar cualquier error que ocurra durante la solicitud
      print('Error connecting pet to user: $e');
    }
  }

  Future<void> _addPetAndConnect(Pet pet) async {
    String userId = widget.user.id;

    // Añadir la mascota
    int petId = await _addPet(pet);

    // Si la mascota se añadió correctamente, conectar la mascota con el usuario
    if (petId != 0) {
      await _connectPetToUser(userId, petId);
    } else {
      CustomSnackBar.show(context, "No se pudo añadir la mascota", true);
    }
  }

  Future<void> _editPet(Pet pet) async {
    final config = await loadConfig();
    try {
      // URL de tu endpoint para agregar mascotas
      final editPet = Uri.parse('http://${config.host}:3000/pet');

      // Convertir el objeto Pet a JSON
      final petJson = pet.toJson();

      // Realizar la solicitud POST para agregar la mascota
      final response = await http.put(
        editPet,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(petJson),
      );

      // Verificar si la solicitud fue exitosa (código de respuesta 200)
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

       CustomSnackBar.show(context, "Mascota editada correctamente", false);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => MyHomePage(
                    user: widget.user,
                    activo: false,
                    rating: false,
                  )),
          (route) => false,
        );
      } else {
        // Si la solicitud no fue exitosa, imprimir el código de respuesta
        print('Error editPet pet. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Manejar cualquier error que ocurra durante la solicitud
      print('Error editPet pet: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animalController.dispose();
    _raceController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}
