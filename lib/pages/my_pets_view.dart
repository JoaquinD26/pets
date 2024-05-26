import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pets/models/pet.dart';
import 'package:pets/models/user.dart';
import 'package:pets/pages/forms/petForm.dart';

class MyPetsView extends StatefulWidget {
  static String id = "pets_page";

  late User user; // Agrega un parámetro para recibir el usuario logeado

  MyPetsView({required this.user, super.key});

  @override
  MyPetsViewState createState() => MyPetsViewState();
}

class MyPetsViewState extends State<MyPetsView> {
  late List<Pet> mascotas = [];
  int _currentMascotaIndex = 0;

  @override
  void initState() {
    super.initState();
    _cargarMascotas();
  }

  void _cargarMascotas() {
    setState(() {
      mascotas = widget.user.pets;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mascotas.isEmpty
          ? AddPetForm(user: widget.user)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddPetForm(user: widget.user,)),
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
                        _buildMascotaEventos(mascotas[_currentMascotaIndex]),
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
