import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pets/components/forum_card.dart';
import 'package:pets/models/user.dart';
import 'package:pets/models/forum.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ForumPage extends StatefulWidget {
  static String id = "forum_page";
  final User userLog;

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
      var response = await http.get(Uri.parse('http://localhost:3000/forum'));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);

        List<Forum> loadedForums = jsonData.map((forumData) {
          return Forum.fromJson(forumData);
        }).toList();

        setState(() {
          forums = loadedForums;
          print(forums[0].description);
        });
      } else {
        print(
            'Error al cargar los foros. Código de respuesta: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al cargar los foros: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange[100],
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              itemCount: forums.length,
              itemBuilder: (context, index) {
                return ForumPostCard(
                  forum: forums[index],
                );
              },
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showPostDialog(context);
        },
        backgroundColor: Colors.deepOrangeAccent,
        child: Icon(color: Colors.white, Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
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
      // Construir el cuerpo de la solicitud
      Map<String, dynamic> body = {
        'name': widget.userLog.name,
        "description": post,
        "user": {"id": widget.userLog.id}
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

        // Decodificar la respuesta JSON y crear una instancia de User

        if (kDebugMode) {
          print('Comentario Añadido');
        }
        // Aquí puedes navegar a la pantalla de inicio de sesión o realizar otras acciones
      } else {
        // Error al registrar usuario
        print('Error al añadir foro: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error al añadir foro: $e');
    }
  }
}
