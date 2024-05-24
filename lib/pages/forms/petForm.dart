import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:pets/models/pet.dart';
import 'package:http/http.dart' as http;
import 'package:pets/models/user.dart';

class AddPetForm extends StatefulWidget {

  late User user;

  AddPetForm({required this.user, super.key});

  @override
  _AddPetFormState createState() => _AddPetFormState();
}

class _AddPetFormState extends State<AddPetForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _animalController = TextEditingController();
  final TextEditingController _raceController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String _selectedGender = 'Male';
  bool _hasChip = false;
  Uint8List? _selectedImageBytes;

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedImageBytes = result.files.single.bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Pet'),
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
                    return 'Please enter the name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _animalController,
                decoration: InputDecoration(
                  labelText: 'Animal',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the animal';
                  }
                  return null;
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
                    return 'Please enter the weight';
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
                          child: Text(label),
                          value: label,
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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Create a new pet
                    Pet newPet = Pet(
                      id: 0, // Assuming ID is auto-generated
                      name: _nameController.text,
                      animal: _animalController.text,
                      race: _raceController.text,
                      weight: double.parse(_weightController.text),
                      gender: _selectedGender == 'Male' ? 0 : 1,
                      chip: _hasChip ? 1 : 0,
                      idUser: '0', // User ID is not used
                      petImg: '', // Image upload handling not covered
                      eventos: [], // Events not included
                    );

                    // Add the pet
                    _addPet(newPet);

                    // Optionally, clear the form
                    _formKey.currentState!.reset();
                    setState(() {
                      _selectedGender = 'Male';
                      _hasChip = false;
                      _selectedImageBytes = null;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange[300],
                ),
                child: Text(
                  'Add Pet',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addPet(Pet pet) async {
    try {
      // URL de tu endpoint para agregar mascotas
      final url = Uri.parse('http://localhost:3000/pet');

      // Convertir el objeto Pet a JSON
      final petJson = pet.toJson();

      // Realizar la solicitud POST
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(petJson),
      );

      // Verificar si la solicitud fue exitosa (código de respuesta 200)
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);

        String userId = widget.user.id as String;
        String petId = responseBody['id'];

        // URL de tu endpoint para agregar conexión a mascotas con el usuario actual
        final url = Uri.parse(
            'http://localhost:3000/pet/$userId/$petId'); //TODO PONER LA ID DEL USUARIO

        // Convertir el objeto Pet a JSON
        final petJson = pet.toJson();

        // Realizar la solicitud POST
        final response2 = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(petJson),
        );

        if (response2.statusCode == 200) {
          // Mostrar un mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pet added successfully')),
          );
        }

      } else {
        // Si la solicitud no fue exitosa, imprimir el código de respuesta
        print('Error adding pet. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Manejar cualquier error que ocurra durante la solicitud
      print('Error adding pet: $e');
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
