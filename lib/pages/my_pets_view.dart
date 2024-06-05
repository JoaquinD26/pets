import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:pets/models/config.dart';
import 'package:pets/models/pet.dart';
import 'package:pets/models/user.dart';
import 'package:pets/pages/Home.dart';
import 'package:pets/pages/forms/pet_form.dart';
import 'package:http/http.dart' as http;
import 'package:pets/utils/custom_snackbar.dart';

class MyPetsView extends StatefulWidget {
  final String id = "pets_page";
  final User userLog; // Agrega un parámetro para recibir el usuario logeado

  const MyPetsView({required this.userLog, super.key});

  @override
  MyPetsViewState createState() => MyPetsViewState();
}

class MyPetsViewState extends State<MyPetsView> {
  late Future<User> _futureUser;
  late List<Pet> mascotas = [];
  int _currentMascotaIndex = 0;

  @override
  void initState() {
    super.initState();
    _futureUser = fetchUserById(widget.userLog.id);
  }

  Future<User> fetchUserById(String id) async {
    final configString = await rootBundle.loadString('assets/config.json');
    final configJson = json.decode(configString);
    final config = Config.fromJson(configJson);

    final response =
        await http.get(Uri.parse('http://${config.host}:3000/user/$id'));
    if (response.statusCode == 200) {
      final user = User.fromJson(json.decode(response.body));
      setState(() {
        mascotas = user.pets!;
      });
      return user;
    } else {
      throw Exception('Failed to load user: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<User>(
        future: _futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return mascotas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Aún no tienes mascotas!!',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.deepOrange[300],
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddPetForm(user: widget.userLog),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange[300],
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Añade tus mascotas aquí',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(height: 20),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirmar eliminación'),
                                content: Text(
                                    '¿Estás seguro de que quieres eliminar este comentario?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      deletePet(
                                          mascotas[_currentMascotaIndex].id);
                                          setState(() {
                                            fetchUserById(widget.userLog.id);
                                          });
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.red,
                                    ),
                                    child: Text('Eliminar'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      SizedBox(
                        height: 300, // Altura fija para el carrusel
                        child: _buildCarousel(),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildMascotaInfo(mascotas[_currentMascotaIndex]),
                              _buildMascotaEventos(
                                  mascotas[_currentMascotaIndex]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPetForm(user: widget.userLog),
            ),
          );
        },
        backgroundColor: Colors.deepOrangeAccent,
        child: Icon(color: Colors.white, Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 400,
        enlargeCenterPage: true,
        autoPlay: false,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: mascotas.length == 1 ? false : true,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.8,
        onPageChanged: (index, _) {
          setState(() {
            _currentMascotaIndex = index;
          });
        },
      ),
      items: mascotas.map((mascota) {
        return Builder(
          builder: (BuildContext context) {
            return _buildMascotaItem(mascota);
          },
        );
      }).toList(),
    );
  }

  Widget _buildMascotaItem(Pet mascota) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddPetForm(
              user: widget.userLog,
              pet: mascota, // Pasar el objeto Pet al formulario
              isEditing: true, // Indicar que se está editando
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  mascota.petImg,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMascotaInfo(Pet mascota) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 22.0),
            child: Container(
              width: double.infinity,
              child: Material(
                borderRadius: BorderRadius.circular(20.0),
                elevation: 6.0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 20.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  height: 240,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            mascota.name,
                            style: TextStyle(
                              fontSize: 26.0,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Tipo: ${mascota.animal}',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Raza: ${mascota.race}',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Peso: ${mascota.weight} kg',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Género: ${mascota.gender == 1 ? "Macho" : "Hembra"}',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Chip: ${mascota.chip == 1 ? "Sí" : "No"}',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMascotaEventos(Pet mascota) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Eventos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: mascota.eventos.map((evento) {
              return Text(
                evento,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> deletePet(int petId) async {
    final configString = await rootBundle.loadString('assets/config.json');
    final configJson = json.decode(configString);
    final config = Config.fromJson(configJson);

    final response =
        await http.delete(Uri.parse('http://${config.host}:3000/pet/$petId'));

    if (response.statusCode == 200) {
      CustomSnackBar.show(context, "Mascota editada correctamente", false);
    } else {
      throw Exception('Failed to load user: ${response.reasonPhrase}');
    }
  }
}
