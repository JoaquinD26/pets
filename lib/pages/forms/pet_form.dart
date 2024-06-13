import 'dart:convert';
import 'dart:io';
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
import 'package:http_parser/http_parser.dart';

class AddPetForm extends StatefulWidget {
  final User user;
  final Pet? pet;
  final bool isEditing;

  AddPetForm({
    required this.user,
    this.pet,
    this.isEditing = false,
    super.key,
  });

  @override
  AddPetFormState createState() => AddPetFormState();
}

class AddPetFormState extends State<AddPetForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _animalController = TextEditingController();
  final TextEditingController _raceController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String _selectedGender = 'Male';
  String _selectedAnimal = "Perro";
  bool _hasChip = false;
  Uint8List? _selectedImageBytes;

  Future<Config> loadConfig() async {
    final configString = await rootBundle.loadString('assets/config.json');
    final configJson = json.decode(configString);
    return Config.fromJson(configJson);
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        setState(() {
          _selectedImageBytes = file.bytes;
        });
      } else {
        print('No file selected');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _initializeControllers() {
    if (widget.isEditing && widget.pet != null) {
      _nameController.text = widget.pet!.name;
      _selectedAnimal = widget.pet!.animal;
      _raceController.text = widget.pet!.race;
      _weightController.text = widget.pet!.weight.toString();
      _selectedGender = widget.pet!.gender == 1 ? 'Male' : 'Female';
      _hasChip = widget.pet!.chip == 1;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeControllers();
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
                    return 'Please enter the name';
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
                items: ['Perro', 'Gato'].map((label) => DropdownMenuItem(
                  value: label,
                  child: Text(label),
                )).toList(),
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
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
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
                items: ['Male', 'Female'].map((label) => DropdownMenuItem(
                  value: label,
                  child: Text(label),
                )).toList(),
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
                child: Text('Pick an image', style: TextStyle(color: Colors.black)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    Pet pet = Pet(
                      id: widget.isEditing ? widget.pet!.id : 0,
                      name: _nameController.text,
                      animal: _selectedAnimal,
                      race: _raceController.text,
                      weight: double.parse(_weightController.text),
                      gender: _selectedGender == 'Male' ? 1 : 0,
                      chip: _hasChip ? 1 : 0,
                      petImg: '',
                      eventos: [],
                    );

                    try {
                      widget.isEditing ? await _editPet(pet) : await _addPetAndConnect(pet);
                    } catch (e) {
                      CustomSnackBar.show(context, "Error al añadir la mascota", true);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange[300],
                ),
                child: Text(
                  widget.isEditing ? 'Edit Pet' : 'Add Pet',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int> _addPet(Pet pet) async {
    final config = await loadConfig();
    try {
      final addPetUrl = Uri.parse('http://${config.host}:3000/pet');
      final petJson = pet.toJson();
      final response = await http.post(
        addPetUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(petJson),
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        int petId = responseBody['id'];
        await uploadPetImage(petId, _selectedImageBytes);
        return petId;
      } else {
        print('Error adding pet. Status code: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('Error adding pet: $e');
      return 0;
    }
  }

  Future<void> uploadPetImage(int petId, Uint8List? imageBytes) async {
    final config = await loadConfig();
    if (imageBytes != null && imageBytes.isNotEmpty) {
      try {
        var url = Uri.parse("http://${config.host}:3000/pet/upload");
        String petIdString = petId.toString();
        var request = http.MultipartRequest('POST', url)
          ..fields['id'] = petIdString
          ..files.add(http.MultipartFile.fromBytes(
            'file',
            imageBytes,
            filename: '${DateTime.now().hashCode}_$petIdString.jpg',
            contentType: MediaType('application', 'octet-stream'),
          ));

        var response = await http.Response.fromStream(await request.send());

        if (response.statusCode == 200) {
          print('Image uploaded successfully');
        } else {
          print('Image upload failed with status: ${response.statusCode}');
          print('Response: ${response.body}');
        }
      } catch (e) {
        print('Error uploading image: $e');
      }
    } else {
      print('No image selected');
    }
  }

  Future<void> _connectPetToUser(String userId, int petId) async {
    final config = await loadConfig();
    try {
      final addPetToUserUrl = Uri.parse('http://${config.host}:3000/user/$userId/$petId');
      final response = await http.get(
        addPetToUserUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
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
        print('Error connecting pet to user. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error connecting pet to user: $e');
    }
  }

  Future<void> _addPetAndConnect(Pet pet) async {
    String userId = widget.user.id;
    int petId = await _addPet(pet);
    if (petId != 0) {
      await _connectPetToUser(userId, petId);
    } else {
      CustomSnackBar.show(context, "No se pudo añadir la mascota", true);
    }
  }

  Future<void> _editPet(Pet pet) async {
    final config = await loadConfig();
    try {
      final editPetUrl = Uri.parse('http://${config.host}:3000/pet');
      final petJson = pet.toJson();
      final response = await http.put(
        editPetUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(petJson),
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        int petId = responseBody['id'];
        await uploadPetImage(petId, _selectedImageBytes);
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
        print('Error editPet. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error editPet: $e');
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
