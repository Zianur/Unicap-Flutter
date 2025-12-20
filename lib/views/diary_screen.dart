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
    super.initState();
    // TODO: implement initState

    Future.delayed(Duration.zero, () async {
      final authController = Provider.of<AuthController>(context, listen: false);
      authController.getCurrentUser();
      userId = authController.user?.uid ?? 'guest';
      debugPrint('=========diary screen=========userid======================$userId');
    });

    initialTitle = widget.diaryEntry?.noteName ?? '';
    initialNote = widget.diaryEntry?.note ?? '';

    _titleController.text = widget.diaryEntry?.noteName ?? '';
    _noteController.text = widget.diaryEntry?.note ?? '';
  }




  @override
  Widget build(BuildContext context) {
    // final double heightSize = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade900,
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
      body: SafeArea(
        child: Column(children: [

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blueGrey.shade900,
                    Colors.grey.shade900,
                  ],
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title Field
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _titleController,
                            cursorColor: Colors.blueAccent.shade200,
                            decoration: InputDecoration(
                              labelText: 'Title',
                              labelStyle: TextStyle(
                                color: Colors.white.withValues(alpha:0.8),
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.blueAccent.shade200,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha:0.07),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              prefixIcon: Icon(
                                Icons.title,
                                color: Colors.white.withValues(alpha:0.7),
                                size: 22,
                              ),
                              counterStyle: TextStyle(
                                color: Colors.white.withValues(alpha:0.5),
                              ),
                            ),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha:0.95),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLength: 100,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Title is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 24),

                        // Note Field
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha:0.2),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _noteController,
                            cursorColor: Colors.tealAccent.shade200,
                            decoration: InputDecoration(
                              hintText: 'Start writing...',
                              hintStyle: TextStyle(
                                color: Colors.tealAccent.shade200,
                                fontSize: 18,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: true,
                              fillColor: Colors.transparent,
                              contentPadding: EdgeInsets.all(16),
                              alignLabelWithHint: true,
                              counterStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 17,
                              height: 1.6,
                              letterSpacing: 0.5,
                            ),
                            keyboardType: TextInputType.multiline,
                            minLines: 10,
                            maxLines: null,
                            maxLength: 30000,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Note is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          Container(
            height: 65,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade900,
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
