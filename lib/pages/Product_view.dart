import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pets/models/config.dart';
import 'dart:convert';
import 'package:pets/models/user.dart';
import 'package:pets/models/Product.dart';
import 'package:pets/pages/products/categories_widget.dart';
import 'package:pets/pages/products/newest_items_widget.dart';
import 'package:pets/pages/products/recent_items_widget.dart'; // Importa el widget PopularItemsWidget

// ignore: must_be_immutable
class ProductView extends StatefulWidget {
  static String id = "product_page";
  User userLog; // Agrega un parámetro para recibir el usuario logeado

  ProductView({Key? key,required this.userLog}) : super(key: key);

  @override
  _ProductViewState createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  late List<Product> allProducts = [];
  late List<Product> displayedProducts = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final configString = await rootBundle.loadString('assets/config.json');
    final configJson = json.decode(configString);
    final config = Config.fromJson(configJson);
    
    final response = await http.get(Uri.parse('http://${config.host}:3000/product'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);

      List<Product> loadedProducts = jsonData.map((productData) {
        return Product.fromJson(productData);
      }).toList();

      setState(() {
        allProducts = loadedProducts;
        displayedProducts =
            loadedProducts; // Inicializa displayedProducts con todos los productos
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  void searchProducts(String query) {
    setState(() {
      isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        // Si la consulta está vacía, mostrar todos los productos
        displayedProducts = allProducts;
      } else {
        // Filtrar productos por nombre
        displayedProducts = allProducts
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  } // Agreg

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: fetchProducts,
        child: ListView(
          children: [
            SizedBox(height: 20,),
            // Search
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 15,
              ),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.red,
                      ),
                      SizedBox(
                        height: 50,
                        width: 300,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          child: TextFormField(
                            onChanged: searchProducts,
                            decoration: InputDecoration(
                              hintText: "¿Qué te gustaría buscar?",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Categories
            Padding(
              padding: EdgeInsets.only(top: 20, left: 10),
              child: Text(
                "Categorias",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            // Categories Widget
            CategoriesWidget(onCategorySelected: onCategorySelected),

            if (!isSearching)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: 10), // Solo aplicamos padding a la izquierda
                    child: Text(
                      "Productos recién añadidos.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  RecentItemsWidget(products: displayedProducts, userLog: widget.userLog),
                ],
              ),

            // Newest Items
            Padding(
              padding: EdgeInsets.only(top: 20, left: 10),
              child: Text(
                "Todos los productos",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            // Newest Item Widget
            displayedProducts.isEmpty
                ? Center(
                    child: Text(
                      "No se encontraron resultados",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : NewestItemsWidget(displayedProducts: displayedProducts, userLog: widget.userLog),
          ],
        ),
      ),
    );
  }

  void onCategorySelected(int categoryId) {
    setState(() {
      displayedProducts = allProducts
          .where((product) => product.category.id == categoryId)
          .toList();
    });
  }
}
