import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicap_cg/controllers/auth_controller.dart';
import 'package:unicap_cg/controllers/diary_controller.dart';
import 'package:unicap_cg/controllers/fav_caption_controller.dart';
import 'package:unicap_cg/services/auth_service.dart';
import 'package:unicap_cg/views/caption_category.dart';
import 'package:unicap_cg/views/fav_caption_screen.dart';
import '../controllers/caption_category_controller.dart';
import 'caption_screen.dart';
import 'diary_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    Provider.of<CaptionCategoryController>(context, listen: false).loadCategories();
  }

  // List of screens for navigation
  final List<Widget> _screens = [
    DiaryScreen(),
    CaptionCategoryView(),
    LoginScreen(),
    FavCaptionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [_screens[_selectedIndex]],
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ), // Display selected screen

      // ✅ Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Diary',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Captions',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Login',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
        ],
      ),
    );
  }
}
