import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicap_cg/common/basewidgets/translation_widget.dart';
import 'package:unicap_cg/controllers/translator_controller.dart';

class TranslationScreen extends StatefulWidget {
  final bool fromCaption;
  const TranslationScreen({super.key, this.fromCaption = false});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {

  @override
  void initState() {
    super.initState();

    if(!widget.fromCaption){
      Provider.of<TranslatorController>(context, listen: false).clearText(isNotify: false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
        body: Padding(
          padding: EdgeInsets.only(top: widget.fromCaption ? 30 : 0),
          child: TranslationWidget(),
        ),
    );
  }
}