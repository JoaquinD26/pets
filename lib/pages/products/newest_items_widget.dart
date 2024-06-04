import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:pets/models/product.dart';
import 'package:pets/pages/products/item_page.dart';

class NewestItemsWidget extends StatefulWidget {
  const NewestItemsWidget({Key? key}) : super(key: key);

  @override
  State<NewestItemsWidget> createState() => _NewestItemsWidgetState();
}

class _NewestItemsWidgetState extends State<NewestItemsWidget> {
  List<Product> products = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('http://localhost:3000/product'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);

      List<Product> loadedProducts = jsonData.map((productData) {
        return Product.fromJson(productData);
      }).toList();
      print("Pruebaa");
      print(jsonData);
      setState(() {
        products = loadedProducts;
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Supongamos que tienes una lista de productos
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          children: products.map((product) {
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
                            builder: (context) => ItemPage(),
                          ),
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Image.network(
                          product.imageUrl, // Usa la URL del producto
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
                          Text(
                            product.description, // Descripción del producto
                            style: TextStyle(
                              fontSize: 14, // Reducido el tamaño del texto
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                          RatingBar.builder(
                            initialRating: 4,
                            minRating: 1,
                            direction: Axis.horizontal,
                            itemCount: 5,
                            itemSize: 16, // Reducido el tamaño de las estrellas
                            itemPadding: EdgeInsets.symmetric(horizontal: 4),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.red,
                            ),
                            onRatingUpdate: (index) {},
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
}