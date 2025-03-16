import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    print('-------inside initState----------------------');
    Provider.of<CaptionController>(context, listen: false).loadCategories();
  }

  // List of screens for navigation
  final List<Widget> _screens = [
    DiaryScreen(),
    CaptionListScreen(),
    LoginScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Caption App")),
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
        ],
      ),
    );
  }
}

// ✅ Caption List Screen (Updated to be used inside navigation)
class CaptionListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final captionController = Provider.of<CaptionController>(context);

    return captionController.categories.isEmpty
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
      itemCount: captionController.categories.length,
      itemBuilder: (context, index) {
        final category = captionController.categories[index];
        return ListTile(
          title: Text(category.name),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CaptionScreen(categoryId: category.name),
              ),
            );
          },
        );
      },
    );
  }
}
