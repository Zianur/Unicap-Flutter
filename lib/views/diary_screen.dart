import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:unicap_cg/common/basewidgets/custom_button_widget.dart';
import 'package:unicap_cg/common/basewidgets/custom_toast_message.dart';
import 'package:unicap_cg/controllers/auth_controller.dart';
import 'package:unicap_cg/controllers/diary_controller.dart';
import 'package:unicap_cg/models/diary_entry.dart';

class DiaryScreen extends StatefulWidget {
  final DiaryEntry? diaryEntry;

  const DiaryScreen({super.key, this.diaryEntry});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String? initialTitle;
  String? initialNote;
  String userId = 'guest';

  @override
  void initState() {
    // TODO: implement initState

    Future.delayed(Duration.zero, () async {
      final authController = Provider.of<AuthController>(context, listen: false);
      authController.getCurrentUser();
      userId = authController.user?.uid ?? 'guest';
      print('=========diary screen=========userid======================$userId');
    });

    initialTitle = widget.diaryEntry?.noteName ?? '';
    initialNote = widget.diaryEntry?.note ?? '';

    _titleController.text = widget.diaryEntry?.noteName ?? '';
    _noteController.text = widget.diaryEntry?.note ?? '';
  }




  @override
  Widget build(BuildContext context) {
    // final double heightSize = MediaQuery.sizeOf(context).height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.deepPurpleAccent,
        appBar: AppBar(
          backgroundColor: Colors.deepPurpleAccent,
          title: Text(widget.diaryEntry == null ? 'Add note' : 'Update note', style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
          )),
          centerTitle: true,
          leading: InkWell(
            onTap: ()=> Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
          ),
        ),
        body: Column(children: [
      
          Expanded(child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Form(
                key: _formKey,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      
                  TextFormField(
                    controller: _titleController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.7), width: 2),
                      ),
                      counterStyle: TextStyle(color: Colors.black),
                    ),
                    style: TextStyle(color: Colors.black),
                    maxLength: 100,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
      
                  TextFormField(
                    controller: _noteController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      labelText: 'Note',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.7), width: 2),
                      ),
                      alignLabelWithHint: true,
                      counterStyle: TextStyle(color: Colors.black),
                    ),
                    style: TextStyle(color: Colors.black),
                    keyboardType: TextInputType.multiline,
                    minLines: 5,
                    maxLines: null,
                    maxLength: 30000,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Note is required';
                      }
                      return null;
                    },
                  ),
      
                ]),
              ),
            ),
          )),
      
          Container(
            height: 65,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurpleAccent.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
      
                Flexible(child: CustomButtonWidget(
                  borderRadius: 100,
                  backgroundColor: Colors.black,
                  buttonText: 'Copy',
                  textStyle: TextStyle(color: Colors.white),
                  onPressed:(){
                    Clipboard.setData(ClipboardData(text: _noteController.text));
                    CustomToast.showToast('Note Copied', ToastType.success, null);
                  },
                )),
                SizedBox(width: 10),
      
                Consumer<DiaryController>(
                    builder: (context, diaryController, _) {
                      return Flexible(child: CustomButtonWidget(
                        isLoading: diaryController.isLoading,
                        borderRadius: 100,
                        backgroundColor: Colors.black,
                        buttonText: widget.diaryEntry == null ? 'Save' : 'Update',
                        textStyle: TextStyle(color: Colors.green),
                        onPressed: () async {
                          final String newTitle = _titleController.text;
                          final String newNote = _noteController.text;
      
                          if(_formKey.currentState!.validate()){
      
                            if(newTitle == initialTitle && newNote == initialNote){
                              CustomToast.showToast("Nothing to update", ToastType.error, null);
                            } else{
                              if(widget.diaryEntry != null){
                                await diaryController.saveNote(
                                    widget.diaryEntry?.userId ?? userId,
                                    newTitle,
                                    widget.diaryEntry?.noteId ?? '',
                                    newNote
                                );
                              }
                              else{
                                await diaryController.saveNote(userId, newTitle, null, newNote);
                              }
      
                              CustomToast.showToast("Note saved successfully", ToastType.success, null);
                              Navigator.pop(context);
                            }
                          }
      
                        },
                      ));
                    }
                ),
              ],
            )),
          ),
        ]),
      ),
    );
  }
}
