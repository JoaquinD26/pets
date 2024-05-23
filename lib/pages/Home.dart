import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pets/pages/forum_view.dart';
import 'package:pets/pages/my_pets_view.dart';
import 'package:pets/pages/profile_view.dart';

class MyHomePage extends StatefulWidget {
  static String id = "home_page";

  const MyHomePage({
    super.key,
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
    _pages = [
      const MyPetsView(),
      const PageTwo(),
      ForumPage(),
      ProfileView(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double iconSize = screenWidth < 400 ? 13.0 : 20.0;

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
        iconSize: iconSize,
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
