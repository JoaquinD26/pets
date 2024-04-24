import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pets/pages/forum_view.dart';
import 'package:pets/pages/my_pets_view.dart';
import 'package:pets/pages/my_profile/my_profile_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    MyPetsView(),
    PageTwo(),
    ForumPage(),
    ProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //NO REDIRIGE Y NO TIENE POR QUE HACERLO, CONTRUYE EL CUERPO DEL SCAFFOLD SEGÚN EL INDEX DE ESTA LISTA DE WIDGETS
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double iconSize = screenWidth < 400
        ? 13.0
        : 20.0; // Establece el tamaño del icono según el ancho de la pantalla

    return Scaffold(
      backgroundColor: Colors.deepOrange[300],
      body: _pages[_selectedIndex],
      bottomNavigationBar: GNav(
        activeColor: Colors.brown[900],
        color: Colors.white,
        tabs: const [
          GButton(
            icon: Icons.pets,
            text: 'My Pets',
          ),
          GButton(
            icon: Icons.search,
            text: 'Search',
          ),
          GButton(
            icon: Icons.forum_outlined,
            text: 'Forum',
          ),
          GButton(
            icon: Icons.person,
            text: 'Profile',
          ),
        ],
        selectedIndex: _selectedIndex,
        onTabChange: _onItemTapped,
        iconSize: iconSize, // Usa el tamaño de icono calculado
      ),
    );
  }
}

class PageTwo extends StatelessWidget {
  const PageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Page 2'),
    );
  }
}
