import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pets/models/Product.dart';
import 'package:pets/models/config.dart';
import 'package:pets/models/user.dart';
import 'package:pets/pages/products/item_page.dart';

class RecentItemsWidget extends StatefulWidget {
  final List<Product> products;
  User userLog;

  RecentItemsWidget({Key? key, required this.products, required this.userLog}) : super(key: key);

  @override
  State<RecentItemsWidget> createState() => _RecentItemsWidgetState();
}

class _RecentItemsWidgetState extends State<RecentItemsWidget> {
  late List<Product> products;
  late Future<Config> configFuture;

  @override
  void initState() {
    super.initState();
    configFuture = loadConfig();
    products = List.from(widget.products);
    products.sort((a, b) => b.id.compareTo(a.id)); // Orden descendente
  }

  Future<Config> loadConfig() async {
    final configString = await rootBundle.loadString('assets/config.json');
    final configJson = json.decode(configString);
    return Config.fromJson(configJson);
  }

  @override
  void didUpdateWidget(covariant RecentItemsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    products = widget.products;
    products.sort((a, b) => b.id.compareTo(a.id)); // Orden descendente
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
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
              child: Row(
                children: products.map((product) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 7),
                    child: Container(
                      width: 200,
                      height: 300,
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
                                    builder: (context) => ItemPage(product: product, userLog: widget.userLog),
                                  ),
                                );
                              },
                              child: Container(
                                alignment: Alignment.center,
                                child: Image.network(
                                  'http://${config.host}/crud/${product.imageUrl}',
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
                            RatingBar.builder(
                                  initialRating: product.averageScore,
                                  minRating: 0,
                                  direction: Axis.horizontal,
                                  allowHalfRating:
                                      true, // Permitir medias estrellas
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
                            SizedBox(height: 4),
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
          );
        }
      },
    );
  }
}
