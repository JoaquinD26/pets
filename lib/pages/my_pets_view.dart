import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:pets/models/config.dart';
import 'package:pets/models/pet.dart';
import 'package:pets/models/user.dart';
import 'package:pets/pages/forms/pet_form.dart';
import 'package:http/http.dart' as http;
import 'package:pets/utils/custom_snackbar.dart';

class MyPetsView extends StatefulWidget {
  final String id = "pets_page";
  User userLog; // Agrega un parámetro para recibir el usuario logeado

  MyPetsView({required this.userLog, super.key});

  @override
  MyPetsViewState createState() => MyPetsViewState();
}

class MyPetsViewState extends State<MyPetsView> {
  late Future<User> _futureUser;
  late List<Pet> mascotas = [];
  int _currentMascotaIndex = 0;
  late Config config;

  @override
  void initState() {
    super.initState();
    _futureUser = fetchUserById(widget.userLog.id);
    loadConfig();
  }

  Future<void> loadConfig() async {
    final configString = await rootBundle.loadString('assets/config.json');
    final configJson = json.decode(configString);
    config = Config.fromJson(configJson);
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

  Future<void> loadUser() async {
    setState(() {
      _futureUser = fetchUserById(widget.userLog.id);
    });
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
                        Text(
                          'Pulsa + para añadir tus mascotas',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.deepOrange[300],
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: Stack(
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                            height: MediaQuery.of(context).size.height,
                            enlargeCenterPage: true,
                            autoPlay: false,
                            aspectRatio: 16 / 9,
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enableInfiniteScroll:
                                mascotas.length == 1 ? false : true,
                            autoPlayAnimationDuration:
                                const Duration(milliseconds: 800),
                            viewportFraction: 1.0,
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
                        ),
                      ],
                    ),
                  );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Espera a que se complete la navegación a AddPetForm
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPetForm(
                user: widget.userLog,
                isEditing: false,
              ),
            ),
          );
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
  // fetchUserById

  Widget _buildMascotaItem(Pet mascota) {
    // Obtener la altura de la pantalla
    double screenHeight = MediaQuery.of(context).size.height;

    // Calcular el 70% de la altura de la pantalla
    double imageHeight = screenHeight * 0.5;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      // Contenedor con una altura fija para expandir el Stack
      height: 300.0, // Ajusta la altura según sea necesario
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            // Stack con la imagen y la tarjeta de información

            Stack(
              children: [
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showPetInfoDialog(
                            context, mascotas[_currentMascotaIndex]);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: CachedNetworkImage(
                          imageUrl:
                              "http://${config.host}/crud/${mascota.petImg}",
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: imageHeight,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: double.minPositive + 250.0,
                    )
                  ],
                ),
                Positioned(
                  top: 10.0, // Ajusta la posición vertical del texto
                  left: 10.0, // Ajusta la posición horizontal del texto
                  child: Text(
                    mascota.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10.0, // Ajusta la posición vertical del texto
                  right: 10.0, // Ajusta la posición horizontal del texto
                  child: IconButton(
                    color: Colors.red,
                    icon: const Icon(Icons.cancel_outlined),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Aviso'),
                            content: Text(
                                '¿La mascota desaparecerá de tu lista, estas seguro?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  deletePet(mascotas[_currentMascotaIndex].id);
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
                ),
                Positioned(
                  bottom: 1.0, // Ajusta la posición vertical de la tarjeta
                  left: 0,
                  right: 0,
                  child: _buildMascotaInfo(mascota),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPetInfoDialog(BuildContext context, Pet mascotaPicked) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Stack(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.height,
                    enlargeCenterPage: true,
                    autoPlay: false,
                    aspectRatio: 16 / 9,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: mascotas.length == 1 ? false : true,
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    viewportFraction: 1.0,
                    onPageChanged: (index, _) {
                      setState(() {
                        _currentMascotaIndex = index;
                      });
                    },
                  ),
                  items: mascotas.map((mascota) {
                    return Builder(
                      builder: (BuildContext context) {
                        return CachedNetworkImage(
                          imageUrl:
                              "http://${config.host}/crud/${mascotaPicked.petImg}",
                          fit: BoxFit.fitWidth,
                          width: double.infinity,
                        );
                      },
                    );
                  }).toList(),
                ),
                Positioned(
                  top: 16.0,
                  right: 16.0,
                  child: IconButton(
                    icon: Icon(Icons.expand_circle_down_outlined,
                        color: Colors.redAccent),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMascotaInfo(Pet mascota) {
    return SingleChildScrollView(
      child: GestureDetector(
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
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                child: Material(
                  borderRadius: BorderRadius.circular(20.0),
                  elevation: 6.0,
                  child: Container(
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 233, 226),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            // CircleAvatar(
                            //   radius: 40.0,
                            //   backgroundImage: NetworkImage(mascota.petImg),
                            // ),
                            SizedBox(width: 20.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mascota.name,
                                    style: TextStyle(
                                      fontSize: 26.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  
                                  Text(
                                    'Animal - ${mascota.animal}',
                                    style: TextStyle(
                                      fontSize: 13.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit,
                                  color: Theme.of(context).primaryColor),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddPetForm(
                                      user: widget.userLog,
                                      pet:
                                          mascota, // Pasar el objeto Pet al formulario
                                      isEditing:
                                          true, // Indicar que se está editando
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        
                        Divider(color: Colors.grey[300]),
                        SizedBox(height: 15.0),
                        _buildInfoRow(
                            Image.asset(
                              "assets/icon/genero.png",
                              height: 25,
                              width: 25,
                            ),
                            'Género',
                            mascota.gender == 1 ? "Macho" : "Hembra"),
                        SizedBox(height: 10.0),
                        _buildInfoRow(
                            Image.asset(
                              "assets/icon/mascota.png",
                              height: 25,
                              width: 25,
                            ),
                            'Raza',
                            '${mascota.race}'),
                        SizedBox(height: 10.0),
                        _buildInfoRow(
                            Image.asset(
                              "assets/icon/peso.png",
                              height: 25,
                              width: 25,
                            ),
                            'Peso',
                            '${mascota.weight} kg'),
                        SizedBox(height: 10.0),
                        _buildInfoRow(
                            Image.asset(
                              "assets/icon/chip.png",
                              height: 25,
                              width: 25,
                            ),
                            'Chip',
                            mascota.chip == 1 ? "Sí" : "No"),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(Image image, String title, String value) {
    return Row(
      children: [
        image,
        SizedBox(width: 10.0),
        Text(
          '$title:',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 10.0),
        Text(
          value,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Future<void> deletePet(int petId) async {
    final configString = await rootBundle.loadString('assets/config.json');
    final configJson = json.decode(configString);
    final config = Config.fromJson(configJson);

    final url = Uri.parse(
        'http://${config.host}:3000/user/${widget.userLog.id}/$petId');
    final response = await http.delete(url);
    // final url2 = Uri.parse('http://${config.host}:3000/user/$petId');
    // await http.delete(url2);

    if (response.statusCode == 200) {
      CustomSnackBar.show(context, "Mascota eliminada correctamente", false);
      setState(() {
        _futureUser = fetchUserById(widget.userLog.id);
      });
    } else {
      throw Exception('Failed to delete pet: ${response.reasonPhrase}');
    }
  }
}
