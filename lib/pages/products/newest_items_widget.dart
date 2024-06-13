import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pets/models/Product.dart';
import 'package:pets/models/config.dart';
import 'package:pets/models/user.dart';
import 'package:pets/pages/products/item_page.dart';

class NewestItemsWidget extends StatefulWidget {
  final List<Product> displayedProducts;
  User userLog;
  NewestItemsWidget({Key? key, required this.displayedProducts,required this.userLog})
      : super(key: key);

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
    displayedProducts.sort((a, b) => a.name.compareTo(b.name));
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
    displayedProducts.sort((a, b) => a.name.compareTo(b.name));
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
                      width: 380,
                      height: 150,
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
                                  builder: (context) =>
                                      ItemPage(product: product,userLog: widget.userLog),
                                ),
                              );
                            },
                            child: Container(
                              alignment: Alignment.center,
                              child: Image.network(
                                'http://${config.host}/crud/${product.imageUrl}',
                                height: 120,
                                width: 150,
                              ),
                            ),
                          ),
                          Container(
                            width: 190,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  product.name,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
                                Text(
                                  "${product.price.toString()}\€",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment
                                  .end, // Alinea el icono en la parte inferior
                              children: [
                                Icon(
                                  Icons.favorite_border,
                                  color: Colors.red,
                                  size: 26,
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
