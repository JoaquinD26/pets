import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pets/models/user.dart';
import 'package:pets/pages/forum_view.dart';
import 'package:pets/pages/map_screen.dart';
import 'package:pets/pages/my_pets_view.dart';
import 'package:pets/pages/product_view.dart';
import 'package:pets/pages/profile/profile_view.dart';

import 'package:pets/providers/view_provider.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  bool activo = false;
  final String id = "home_page";
  User user;

  MyHomePage({
    super.key,
    required this.user,
    required this.activo,
  });

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    if (widget.activo) {
      _selectedIndex = 3;
    }
    _pages = [
      MyPetsView(userLog: widget.user),
      ProductView(
        userLog: widget.user,
      ),
      ForumPage(
        userLog: widget.user,
      ),
      // ForumPage(
      //   userLog: widget.user,
      // ),
      ProfileView(userLog: widget.user),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavBarVisibility = Provider.of<ViewProvider>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double iconSize = screenWidth < 400 ? 16.0 : 24.0;

    return Visibility(
      visible: bottomNavBarVisibility.isVisible,
      child: Scaffold(
        backgroundColor: Colors.deepOrange[300],
        body: _pages[_selectedIndex],
        bottomNavigationBar: GNav(
          activeColor: Colors.brown[900],
          color: Colors.white,
          tabs: const [
            GButton(
              icon: Icons.pets,
              // text: 'Mascotas',
            ),
            GButton(
              icon: Icons.shopping_bag_outlined,
              // text: 'Tienda',
            ),
            // GButton(
            //   icon: Icons.navigation_sharp,
            //   text: '',
            // ),
            GButton(
              icon: Icons.forum_outlined,
              // text: 'Foro',
            ),
            GButton(
              icon: Icons.person,
              // text: 'Perfil',
            ),
          ],
          selectedIndex: _selectedIndex,
          onTabChange: _onItemTapped,
          iconSize: iconSize,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MapScreen()),
            );
          },
          backgroundColor: Colors.deepOrangeAccent,
          child: Icon(color: Colors.white, Icons.navigation_sharp),
          mini: true,
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
      ),
    );
  }
}
