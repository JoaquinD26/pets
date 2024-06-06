import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pets/models/Product.dart';
import 'package:pets/models/config.dart';
import 'package:pets/pages/products/item_page.dart';

class NewestItemsWidget extends StatefulWidget {
  final List<Product> displayedProducts;

  const NewestItemsWidget({Key? key, required this.displayedProducts}) : super(key: key);

  @override
  State<NewestItemsWidget> createState() => _NewestItemsWidgetState();
}

class _NewestItemsWidgetState extends State<NewestItemsWidget> {
  late List<Product> displayedProducts;
  late Future<Config> configFuture;

  @override
  void initState() {
    super.initState();
    configFuture = loadConfig();
    displayedProducts = List.from(widget.displayedProducts);
    displayedProducts.sort((a, b) => a.name.compareTo(b.name)); // ORDEN DE ABECEDARIO
  }

  Future<Config> loadConfig() async {
    final configString = await rootBundle.loadString('assets/config.json');
    final configJson = json.decode(configString);
    return Config.fromJson(configJson);
  }

  @override
  void didUpdateWidget(covariant NewestItemsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    displayedProducts = List.from(widget.displayedProducts);
    displayedProducts.sort((a, b) => a.name.compareTo(b.name)); // ORDEN DE ABECEDARIO
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Config>(
      future: configFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading configuration'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('Configuration not found'));
        } else {
          final config = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Column(
                children: displayedProducts.map((product) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      width: 360, // Reducido el ancho del contenedor
                      height: 140, // Reducida la altura del contenedor
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemPage(product: product),
                                ),
                              );
                            },
                            child: Container(
                              alignment: Alignment.center,
                              child: Image.network(
                                'http://${config.host}/crud/${product.imageUrl}', // Usa la URL del producto
                                height: 100, // Reducida la altura de la imagen
                                width: 120, // Reducido el ancho de la imagen
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 160, // Reducido el ancho del contenido textual
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  product.name, // Nombre del producto
                                  style: TextStyle(
                                    fontSize: 18, // Reducido el tamaño del texto
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.favorite_border,
                                  color: Colors.red,
                                  size: 24, // Reducido el tamaño del icono
                                ),
                                Text(
                                  "${product.price.toString()}€", // Precio del producto
                                  style: TextStyle(
                                    fontSize: 18, // Reducido el tamaño del texto
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        }
      },
    );
  }
}
