import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clippy_flutter/arc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pets/models/Product.dart';
import 'package:pets/models/config.dart';
import 'package:http/http.dart' as http;

class ItemPage extends StatefulWidget {
  final Product product;

  const ItemPage({Key? key, required this.product}) : super(key: key);

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
      var response =
          await http.get(Uri.parse('http://${config.host}:3000/forum'));

      if (response.statusCode == 200) {
        setState(() {
          comments = json.decode(response.body);
        });
      } else {
        print(
            'Error al cargar los comentarios. Código de respuesta: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al cargar los comentarios: $e');
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
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
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
                                    initialRating: 1,
                                    ignoreGestures: true,
                                    //initialRating: widget.product.rating,
                                    minRating: 0,
                                    direction: Axis.horizontal,
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
                        Text(
                          'Valoraciones',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                            height:
                                10), // Ajusta este valor según sea necesario
                        ...comments.map((comment) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      comment['name'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    RatingBar.builder(
                                      initialRating: comment['rating'] != null
                                          ? comment['rating']
                                          : 0,
                                      ignoreGestures: true,
                                      minRating: 0,
                                      direction: Axis.horizontal,
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
                                Text(comment['description']),
                              ],
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
