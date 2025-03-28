import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicap_cg/controllers/auth_controller.dart';
import 'package:unicap_cg/controllers/diary_controller.dart';
import 'package:unicap_cg/services/auth_service.dart';
import 'package:unicap_cg/views/caption_category.dart';
import '../controllers/caption_controller.dart';
import 'caption_screen.dart';
import 'diary_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Provider.of<CaptionCategoryController>(context, listen: false).loadCategories();

    /// Get Notes
    final AuthController authController = Provider.of<AuthController>(context, listen: false);
    if(authController.isLoggedIn){
      String? userId = authController.user?.uid;
      Provider.of<DiaryController>(context, listen: false).fetchAndSaveNotes(userId ?? '');
    }

  }

  // List of screens for navigation
  final List<Widget> _screens = [
    CaptionCategory(),
    DiaryScreen(),
    LoginScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Display selected screen

      // ✅ Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Captions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Diary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Login',
          ),
        ],
      ),
    );
  }
}
