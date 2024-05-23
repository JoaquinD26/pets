import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pets/models/Pet.dart';

class MyPetsView extends StatefulWidget {
  static String id = "pets_page";
  const MyPetsView({Key? key}) : super(key: key);

  @override
  MyPetsViewState createState() => MyPetsViewState();
}

class MyPetsViewState extends State<MyPetsView> {
  late List<Pet> _mascotas = [];
  int _currentMascotaIndex = 0;

  @override
  void initState() {
    super.initState();
    _cargarMascotas();
  }

  Future<void> _cargarMascotas() async {
    final response = await http.get(Uri.parse('http://localhost:3000/pet'));
    if (response.statusCode == 200) {
      List<dynamic> mascotasData = json.decode(response.body);
      List<Pet> mascotas = mascotasData.map((mascotaData) {
        return Pet.fromJson(mascotaData);
      }).toList();
      if (kDebugMode) {
        print(response.body);
      }
      setState(() {
        _mascotas = mascotas;
      });
    } else {
      throw Exception('Failed to load pets');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _mascotas.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => {},
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
                        _buildMascotaInfo(_mascotas[_currentMascotaIndex]),
                        _buildMascotaEventos(_mascotas[_currentMascotaIndex]),
                      ],
                    ),
                  ),
                ),
              ],
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
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.8,
        onPageChanged: (index, _) {
          setState(() {
            _currentMascotaIndex = index;
          });
        },
      ),
      items: _mascotas.map((mascota) {
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
            'Chip: ${mascota.chip ? "Sí" : "No"}',
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
