import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/caption_category_controller.dart';

class CaptionScreen extends StatefulWidget {
  final String categoryId;
  const CaptionScreen({super.key, required this.categoryId});

  @override
  _CaptionScreenState createState() => _CaptionScreenState();
}

class _CaptionScreenState extends State<CaptionScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final captionController = Provider.of<CaptionCategoryController>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Captions")),
      body: captionController.captions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: captionController.captions.length,
        itemBuilder: (context, index) {
          final caption = captionController.captions[index];
          return ListTile(
            title: Text(caption.caption),
            trailing: IconButton(
              icon: Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: caption.caption));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Caption copied!")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
