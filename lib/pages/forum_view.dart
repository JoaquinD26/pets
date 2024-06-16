import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pets/components/forum_card.dart';
import 'package:pets/models/config.dart';
import 'package:pets/models/forum.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pets/models/user.dart';
import 'package:pets/utils/custom_snackbar.dart';

class ForumPage extends StatefulWidget {
  static String id = "forum_page";
  User userLog;
  ForumPage({required this.userLog, super.key});

  @override
  ForumPageState createState() => ForumPageState();
}

class ForumPageState extends State<ForumPage> {
  List<Forum> forums = [];
  String post = 'Mensaje nulo';

  List<Forum> filteredForums = [];
  TextEditingController searchController = TextEditingController();

  Future<void> loadForums() async {
    final configString = await rootBundle.loadString('assets/config.json');
    final configJson = json.decode(configString);
    final config = Config.fromJson(configJson);

    try {
      var response =
          await http.get(Uri.parse('http://${config.host}:3000/forum'));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        List<Forum> loadedForums = jsonData.map((forumData) {
          return Forum.fromJson(forumData);
        }).toList();

        loadedForums = loadedForums.reversed.toList();

        setState(() {
          forums = loadedForums;
          filteredForums = loadedForums;
        });
      } else {
        print(
            'Error al cargar los foros. Código de respuesta: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al cargar los foros: $e');
    }
  }

  void filterForums(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredForums = forums;
      });
    } else {
      setState(() {
        filteredForums = forums.where((forum) {
          final titleLower = forum.name.toLowerCase();
          final userLower = forum.user.name.toLowerCase();
          final descriptionLower = forum.description.toLowerCase();
          final queryLower = query.toLowerCase();

          return titleLower.contains(queryLower) ||
              userLower.contains(queryLower) ||
              descriptionLower.contains(queryLower);
        }).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadForums();
    searchController.addListener(() {
      filterForums(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: loadForums,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(height: 20),
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
                            controller: searchController,
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
            ListView.builder(
              shrinkWrap:
                  true, // Importante para que funcione dentro de otro ListView
              physics:
                  NeverScrollableScrollPhysics(), // Para desactivar el scroll interno
              itemCount: filteredForums.length,
              itemBuilder: (context, index) {
                return ForumPostCard(
                  forum: filteredForums[index],
                  userLog: widget.userLog,
                );
              },
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showPostDialog(context);
        },
        backgroundColor: Colors.orange,
        child: Icon(color: Colors.white, Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showPostDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController postController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        // Variable para mantener el nodo de enfoque del primer campo de texto
        FocusNode titleFocusNode = FocusNode();

        // Función para cerrar el nodo de enfoque del primer campo de texto
        void closeFocusNode() {
          titleFocusNode.unfocus();
        }

        // // Enfoca automáticamente el primer campo de texto una vez que el modal se ha construido
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   titleFocusNode.requestFocus();
        // });

        return GestureDetector(
          onTap:
              closeFocusNode, // Cierra el teclado al tocar fuera del campo de texto
          child: FractionallySizedBox(
            heightFactor: 0.9,
            alignment: Alignment.topCenter,
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Añadir Comentario',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.0),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.deepOrange[300],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                            controller: titleController,
                            focusNode:
                                titleFocusNode, // Establece el nodo de enfoque del primer campo de texto
                            decoration: InputDecoration(
                              hintText: 'Título del comentario...',
                              hintStyle: TextStyle(color: Colors.white),
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                CustomSnackBar.show(context,
                                    "Escriba su título antes de enviar", true);
                                return "";
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.deepOrange),
                            controller: postController,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: 'Escribe tu comentario aquí...',
                              hintStyle: TextStyle(color: Colors.deepOrange),
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                CustomSnackBar.show(
                                    context,
                                    "Escriba su comentario antes de enviar",
                                    true);
                                return "";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        String title = titleController.text;
                        String post = postController.text;

                        // Implementa la lógica para enviar el comentario al servidor
                        _postPost(title, post);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepOrange,
                      shadowColor: Colors.deepOrangeAccent,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 12.0),
                    ),
                    child: Text(
                      'Enviar',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _postPost(String title, String post) async {
    final configString = await rootBundle.loadString('assets/config.json');
    final configJson = json.decode(configString);
    final config = Config.fromJson(configJson);

    try {
      DateFormat formatter = DateFormat('yyyy-MM-dd');
      var fechaDeHoy = formatter.format(DateTime.now());

      if (kDebugMode) {
        print(fechaDeHoy);
      }

      // Construir el cuerpo de la solicitud
      Map<String, dynamic> body = {
        "name": title,
        "description": post,
        "user": {"id": widget.userLog.id},
        "likes": "0",
        "date": fechaDeHoy
      };

      // Realizar la solicitud POST al servidor
      var response = await http.post(
        Uri.parse('http://${config.host}:3000/forum'),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      // Verificar si la solicitud fue exitosa
      if (response.statusCode == 200) {
        // Usuario autenticado exitosamente

        CustomSnackBar.show(context, "Foro añadido correctamente", false);

        // Recargar los foros después de añadir el comentario
        loadForums();
      } else {
        CustomSnackBar.show(context, "Error al añadir foro", true);
        print('Error al añadir foro: ${response.reasonPhrase}');
      }
    } catch (e) {
      CustomSnackBar.show(context, "Error al añadir foro", true);
      print('Error al añadir foro: $e');
    }
  }
}
