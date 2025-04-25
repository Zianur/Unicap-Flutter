import 'package:flutter/material.dart';

class WebAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WebAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 4,
      title: Row(
        children: [
          Icon(Icons.flash_on, color: Colors.blueAccent),
          SizedBox(width: 10),
          Text(
            'MyWebApp',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Spacer(),
          if (!isMobile) ..._buildMenuItems(),
          if (isMobile)
            IconButton(
              icon: Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems() {
    final items = ['Home', 'About', 'Services', 'Contact'];
    return items
        .map((item) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        item,
        style: TextStyle(color: Colors.black, fontSize: 16),
      ),
    ))
        .toList();
  }
}

class ResponsiveScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: ['Home', 'About', 'Services', 'Contact']
              .map((text) => ListTile(title: Text(text)))
              .toList(),
        ),
      ),
      appBar: WebAppBar(),
      body: Center(
        child: Text(
          'Responsive AppBar for Web',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
