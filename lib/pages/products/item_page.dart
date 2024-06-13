import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clippy_flutter/arc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pets/models/Product.dart';
import 'package:pets/models/config.dart';
import 'package:http/http.dart' as http;
import 'package:pets/models/user.dart';
import 'package:pets/pages/home.dart';

class ItemPage extends StatefulWidget {
  final Product product;
  User userLog;

  ItemPage({Key? key, required this.product, required this.userLog})
      : super(key: key);

  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  late Future<Config> configFuture;
  List<dynamic> comments = [];

  @override
  void initState() {
    super.initState();
    configFuture = loadConfig();
    loadComments();
  }

  Future<Config> loadConfig() async {
    final configString = await rootBundle.loadString('assets/config.json');
    final configJson = json.decode(configString);
    return Config.fromJson(configJson);
  }

  Future<void> loadComments() async {
    final configString = await rootBundle.loadString('assets/config.json');
    final configJson = json.decode(configString);
    final config = Config.fromJson(configJson);

    try {
      var response = await http.get(Uri.parse(
          'http://${config.host}:3000/productComment/product/${widget.product.id}'));

      if (response.statusCode == 200) {
        setState(() {
          comments = json.decode(response.body);
          print('Comentarios cargados: $comments');
        });
      } else {
        print(
            'Error al cargar los comentarios. Código de respuesta: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al cargar los comentarios: $e');
    }
  }

  Future<void> showAddCommentDialog(BuildContext context) async {
    final TextEditingController commentController = TextEditingController();
    double rating = 0;

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Añadir comentario',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: RatingBar.builder(
                      initialRating: rating,
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 40,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (newRating) {
                        rating = newRating;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: commentController,
                    maxLength: 250,
                    decoration: InputDecoration(
                      labelText: 'Comentario',
                      labelStyle: TextStyle(color: Colors.blueGrey[700]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                      filled: true,
                      fillColor: Colors.blueGrey[50],
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: Text(
                          'Enviar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () async {
                          final comment = {
                            "text": commentController.text,
                            "scoreUser": rating.toString(),
                            "product": {"id": widget.product.id},
                            "user": {
                              "id": widget.userLog.id
                            } // Reemplaza con el ID del usuario real
                          };

                          await sendComment(comment);

                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> sendComment(Map<String, dynamic> comment) async {
    try {
      // Cargar la configuración desde el archivo config.json
      final configString = await rootBundle.loadString('assets/config.json');
      final configJson = json.decode(configString);
      final config = Config.fromJson(configJson);

      // Realizar la solicitud POST para enviar el comentario
      var response = await http.post(
        Uri.parse('http://${config.host}:3000/productComment'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(comment),
      );

      // Verificar el código de respuesta del servidor
      if (response.statusCode == 200) {
        // Actualizar el averageScore del producto después de enviar el comentario
        await updateProductAverageScore(config);
        // Recargar los comentarios
        loadComments(); // Esto actualizará los comentarios en la página
      } else {
        print(
            'Error al enviar el comentario. Código de respuesta: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al enviar el comentario: $e');
    }
  }

  Future<void> updateProductAverageScore(Config config) async {
    try {
      // Realizar la solicitud GET para obtener el averageScore del producto
      var response = await http.get(
        Uri.parse(
            'http://${config.host}:3000/product/${widget.product.id}/averageScore'),
      );

      // Verificar el código de respuesta del servidor
      if (response.statusCode == 200) {
        // Convertir el cuerpo de la respuesta a un double
        var averageScore = double.parse(response.body);
        // Actualizar el estado del widget con el nuevo averageScore
        setState(() {
          widget.product.averageScore = averageScore;
        });
      } else {
        print(
            'Error al obtener el averageScore del producto. Código de respuesta: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener el averageScore del producto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Config>(
      future: configFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Loading...'),
              backgroundColor: Colors.deepOrange[300],
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Error'),
              backgroundColor: Colors.deepOrange[300],
            ),
            body: Center(child: Text('Error loading configuration')),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Error'),
              backgroundColor: Colors.deepOrange[300],
            ),
            body: Center(child: Text('Configuration not found')),
          );
        } else {
          final config = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.product.name,
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.deepOrange[300],
              // Dentro del AppBar de ItemPage
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyHomePage(
                              user: widget.userLog,
                              rating: true,
                              activo: false,
                            )),
                    (route) => false,
                  );
                },
              ),
            ),
            body: Padding(
              padding: EdgeInsets.only(top: 5),
              child: ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Image.network(
                      'http://${config.host}/crud/${widget.product.imageUrl}',
                      height: 300,
                    ),
                  ),
                  Arc(
                    edge: Edge.TOP,
                    arcType: ArcType.CONVEY,
                    height: 30,
                    child: Container(
                      width: double.infinity,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 60, bottom: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  RatingBar.builder(
                                    initialRating: widget.product.averageScore,
                                    minRating: 0,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemSize: 18,
                                    ignoreGestures: true,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 4),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (index) {},
                                  ),
                                  Text(
                                    "${widget.product.price}\€",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.product.name,
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                widget.product.description,
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 10),
                        MaterialButton(
                          onPressed: () {
                            showAddCommentDialog(context);
                          },
                          color: Colors.orange, // Cambia el color de fondo
                          textColor: Colors.white, // Cambia el color del texto
                          padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10), // Ajusta el padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                12.0), // Añade bordes redondeados
                          ),
                          child: Text(
                            'Añadir valoracion',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        if (comments.isEmpty)
                          Text('No hay valoraciones disponibles.'),
                        ...comments.map((comment) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        comment['user']['name'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      RatingBar.builder(
                                        initialRating:
                                            comment['scoreUser'] != null
                                                ? comment['scoreUser']
                                                : 0,
                                        ignoreGestures: true,
                                        minRating: 0,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemSize: 18,
                                        itemPadding:
                                            EdgeInsets.symmetric(horizontal: 4),
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        onRatingUpdate: (index) {},
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Text(comment['text']),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
