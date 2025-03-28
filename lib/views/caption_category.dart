import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicap_cg/controllers/caption_controller.dart';
import 'package:unicap_cg/views/caption_screen.dart';

class CaptionCategory extends StatefulWidget {
  const CaptionCategory({super.key});

  @override
  State<CaptionCategory> createState() => _CaptionCategoryState();
}

class _CaptionCategoryState extends State<CaptionCategory> {
  @override
  Widget build(BuildContext context) {
    final captionController = Provider.of<CaptionCategoryController>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Caption Category")),
      body: captionController.categories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: captionController.categories.length,
        itemBuilder: (context, index) {
          final category = captionController.categories[index];
          return ListTile(
            title: Text(category.name ?? ''),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CaptionScreen(categoryId: category.name ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
