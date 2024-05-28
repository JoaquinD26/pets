import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pets/models/pet.dart';
import 'package:pets/models/user.dart';
import 'package:pets/pages/forms/pet_form.dart';
import 'package:http/http.dart' as http;

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
    _futureUser = fetchUserById(widget.userLog.id!);
  }

  Future<User> fetchUserById(int id) async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/user/$id'));
    if (response.statusCode == 200) {
      final user = User.fromJson(json.decode(response.body));
      setState(() {
        mascotas = user.pets;
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
                        icon: const Icon(Icons.add),
                        onPressed: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddPetForm(user: widget.userLog),
                            ),
                          )
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
    );
  }

  Widget _buildCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 400,
        enlargeCenterPage: true,
        autoPlay: true,
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
    return Container(
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
    );
  }

  Widget _buildMascotaInfo(Pet mascota) {
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
          Text(
            mascota.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Tipo: ${mascota.animal}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Text(
            'Raza: ${mascota.race}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Text(
            'Peso: ${mascota.weight} kg',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Text(
            'Género: ${mascota.gender == 1 ? "Macho" : "Hembra"}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Text(
            'Chip: ${mascota.chip == 1 ? "Sí" : "No"}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
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
}
