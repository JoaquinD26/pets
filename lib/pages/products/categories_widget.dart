// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

import 'package:pets/models/category.dart';

class CategoriesWidget extends StatefulWidget {
  final Function(int) onCategorySelected;

  const CategoriesWidget({Key? key, required this.onCategorySelected})
      : super(key: key);

  @override
  _CategoriesWidgetState createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget> {
  late List<Category> categories =
      []; // Inicializamos categories con una lista vacía

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/product/category'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      List<Category> fetchedCategories = jsonData.map((categoryData) {
        return Category.fromJson(categoryData);
      }).toList();
      setState(() {
        categories = fetchedCategories;
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    return categories
            .isNotEmpty // Verificamos si categories no está vacío antes de mostrarlo
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                  child: Row(
                    children: [
                      for (var category in categories)
                        _buildCategoryItem(context, category.id, () {
                          widget.onCategorySelected(category.id);
                        }),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Center(
            child:
                CircularProgressIndicator(), // Mostramos un indicador de carga mientras se cargan las categorías
          );
  }

  Widget _buildCategoryItem(
      BuildContext context, int categoryId, VoidCallback onTap) {
    // Obtener el nombre de la categoría
    String categoryName = categories
        .firstWhere((category) => category.id == categoryId,
            orElse: () => Category(
                id: categoryId,
                name:
                    'Default') // Si no se encuentra la categoría, utiliza 'Default'
            )
        .name;

    String imageUrl = 'assets/images/${categoryName.toLowerCase()}.jpg';

    // Construir y devolver el widget de la categoría
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Agrega la imagen aquí
                  Image.asset(
                    imageUrl,
                    width:
                        50, // Ajusta el ancho de la imagen según sea necesario
                    height:
                        50, // Ajusta la altura de la imagen según sea necesario
                    fit: BoxFit
                        .cover, // Ajusta la forma en que la imagen se ajusta dentro del contenedor
                  ),
                  SizedBox(
                      height:
                          5), // Ajusta la separación entre la imagen y el texto
                  Text(
                    categoryName, // Utiliza el nombre de la categoría obtenido dinámicamente
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
