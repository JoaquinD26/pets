import 'package:flutter/material.dart';
import 'package:pets/components/forumCard.dart';
import 'package:pets/models/forum.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ForumPage extends StatefulWidget {
  static String id = "forum_page";
  const ForumPage({super.key});

  @override
  ForumPageState createState() => ForumPageState();
}

class ForumPageState extends State<ForumPage> {
  List<Forum> forums = [];

  @override
  void initState() {
    super.initState();
    // Load forum posts when the page initializes
    loadForums();
  }

  void loadForums() async {
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
                    String post = postController.text;
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

  void _postPost(String post) {
    // Implementa aquí la lógica para enviar el comentario al servidor
  }
}
