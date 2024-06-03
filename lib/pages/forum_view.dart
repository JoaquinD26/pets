import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pets/components/forum_card.dart';
import 'package:pets/models/forum.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pets/models/user.dart';

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

  @override
  void initState() {
    super.initState();
    // Load forum posts when the page initializes
    loadForums();
  }

  Future<void> loadForums() async {
    try {
      // Realizar la solicitud HTTP GET a la API
      var response = await http.get(Uri.parse('http://localhost:3000/forum'));

      // Verificar si la solicitud fue exitosa (código de respuesta 200)
      if (response.statusCode == 200) {
        // Decodificar la cadena JSON
        List<dynamic> jsonData = json.decode(response.body);

        // Crear objetos Forum
        List<Forum> loadedForums = jsonData.map((forumData) {
          return Forum.fromJson(forumData);
        }).toList();

        // Invertir el orden de la lista
        loadedForums = loadedForums.reversed.toList();

        // Actualizar el estado con las publicaciones del foro obtenidas de la API
        setState(() {
          forums = loadedForums;
        });
      } else {
        // Si la solicitud no fue exitosa, imprimir el código de respuesta
        print('Error al cargar los foros. Código de respuesta: ${response.statusCode}');
      }
    } catch (e) {
      // Manejar cualquier error que ocurra durante la solicitud
      print('Error al cargar los foros: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: RefreshIndicator(
        onRefresh: loadForums,
        child: Column(
          children: [
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
                  ]),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.search,
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
                          decoration: InputDecoration(
                            hintText: "What would you like to have?",
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
            Flexible(
              child: ListView.builder(
                itemCount: forums.length,
                itemBuilder: (context, index) {
                  return ForumPostCard(
                    forum: forums[index],
                    userLog: widget.userLog,
                  );
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showPostDialog(context);
        },
        backgroundColor: Colors.deepOrangeAccent,
        child: Icon(color: Colors.white, Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _showPostDialog(BuildContext context) {
    TextEditingController postController = TextEditingController();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.9, // Altura del 90% de la pantalla
          alignment: Alignment.topCenter, // Aparece desde arriba
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
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                    controller: postController,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu comentario aquí...',
                      hintStyle: TextStyle(color: Colors.white),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    post = postController.text;

                    // Implementa la lógica para enviar el comentario al servidor
                    _postPost(post);
                    Navigator.pop(context);
                  },
                  child: Text('Enviar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _postPost(String post) async {
    try {


      DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      var fechaDeHoy = formatter.format(DateTime.now());

      if(kDebugMode){
          print(fechaDeHoy);
      }
      
      // Construir el cuerpo de la solicitud
      Map<String, dynamic> body = {
        "name": widget.userLog.name,
        "description": post,
        "user": {"id": widget.userLog.id},
        "likes": "0",
      };

      // Realizar la solicitud POST al servidor
      var response = await http.post(
        Uri.parse('http://localhost:3000/forum'),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      // Verificar si la solicitud fue exitosa
      if (response.statusCode == 200) {
        // Usuario autenticado exitosamente

        if (kDebugMode) {
          print('Comentario Añadido');
        }
        // Recargar los foros después de añadir el comentario
        loadForums();
      } else {
        // Error al registrar usuario
        print('Error al añadir foro: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error al añadir foro: $e');
    }
  }
}
