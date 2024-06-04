import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pets/models/product.dart';
import 'package:pets/pages/products/item_page.dart';

class PopularItemsWidget extends StatefulWidget {
  const PopularItemsWidget({Key? key}) : super(key: key);

  @override
  State<PopularItemsWidget> createState() => _PopularItemsWidgetState();
}

class _PopularItemsWidgetState extends State<PopularItemsWidget> {
  List<Product> products = [];


  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('http://localhost:3000/product'));
    if (response.statusCode == 200) {

      List<dynamic> jsonData = json.decode(response.body);


      List<Product> loadedProducts = jsonData.map((productData) {
        return Product.fromJson(productData);
      }).toList();

      setState(() {
        products = loadedProducts;
      });


    } else {
      throw Exception('Failed to load products');
    }


    
  }

  @override
  Widget build(BuildContext context) {
    fetchProducts();  

    return ListView.builder(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
          child: Row(
            children: products.map((product) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 7),
                child: Container(
                  width: 200,
                  height: 250,
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
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            child: Image.asset(
                              product.imageUrl,
                              height: 130,
                            ),
                          ),
                        ),
                        SizedBox(height: 8), // Add some space between image and text
                        Text(
                          product.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          product.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${product.price.toString()}€",
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.favorite_border,
                              color: Colors.red,
                              size: 26,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
