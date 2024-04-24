// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'PetApp demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   MyHomePageState createState() => MyHomePageState();
// }

// class MyHomePageState extends State<MyHomePage> {
//   int _selectedIndex = 0;

//   final List<Widget> _pages = [
//     const PageOne(),
//     const PageTwo(),
//     const PageThree(),
//     const PageFour(),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PetApp demo'),
//       ),
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Colors.grey[900],
//         unselectedItemColor: Colors.grey[400],
//         selectedItemColor: Colors.black,
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Page 1',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.search),
//             label: 'Page 2',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.notifications),
//             label: 'Page 3',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Page 4',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }

// class PageOne extends StatelessWidget {
//   const PageOne({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('Page 1'),
//     );
//   }
// }

// class PageTwo extends StatelessWidget {
//   const PageTwo({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('Page 2'),
//     );
//   }
// }

// class PageThree extends StatelessWidget {
//   const PageThree({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('Page 3'),
//     );
//   }
// }

// class PageFour extends StatelessWidget {
//   const PageFour({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('Page 4'),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:pets/pages/forum_view.dart';
import 'package:pets/pages/profile_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PetApp demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
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

  /// Lista de Widgets para el intercambio de body del Widget principal, Ejem/Comparación: actua como una lista de fragments en java
  final List<Widget> _pages = [
    const PageOne(),
    const PageTwo(),
    const ForumPage(),
    const ProfileView(),
  ];
  /// Actua como comunicador entre el BottomBar y la página que se muestra, cambiando el index de la lista de Widgets _pages
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('PetApp demo'),
        ),
        // Se establece como body del Widget principal de MyHomePageState una lista de widgets que cambiará dinámicamente según el método _onItemTapped()
        body: _pages[_selectedIndex],
        //Uso de MauseRegion debido a la emulacion web, posibles cambios
        bottomNavigationBar: MouseRegion(
          cursor: SystemMouseCursors.click,
          // Curved Navigation Bar es una dependencia externa implementada en el pubspec.yaml, posible error al pulsar varias veces mientras la animación siguen en curso. 
          child: CurvedNavigationBar(
            backgroundColor: Colors.white,
            color: Colors.grey,
            buttonBackgroundColor: Colors.white,
            height: 50,
            items: const <Widget>[
              Icon(Icons.home, size: 30),
              Icon(Icons.search, size: 30),
              Icon(Icons.forum_outlined, size: 30),
              Icon(Icons.person, size: 30),
            ],
            onTap: _onItemTapped,
          ),
        ));
  }
}
//TODO, Las páginas no irán en el main, falta estructuración del proyecto, directorios, clases, etc... 
class PageOne extends StatelessWidget {
  const PageOne({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Page 1'),
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
