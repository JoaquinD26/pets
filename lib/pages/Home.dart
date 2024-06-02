import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pets/models/user.dart';
import 'package:pets/pages/forum_view.dart';
import 'package:pets/pages/my_pets_view.dart';
import 'package:pets/pages/profile/profile_view.dart';
import 'package:pets/pages/product_view.dart';
import 'package:pets/providers/view_provider.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  bool activo = false;
  final String id = "home_page";
  final User user;

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
    if (widget.activo){
      _selectedIndex = 3;
    }
    _pages = [
      MyPetsView(userLog: widget.user),
      ProductView(
        user: widget.user,
      ),
      ForumPage(
        userLog: widget.user,
      ),
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
    double iconSize = screenWidth < 400 ? 13.0 : 20.0;

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
      ),
    );
  }
}
