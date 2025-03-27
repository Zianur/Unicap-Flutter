import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicap_cg/controllers/auth_controller.dart';
import 'package:unicap_cg/controllers/diary_controller.dart';

class DiaryScreen extends StatefulWidget {

  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  String? userId;

  @override
  void initState() {

    userId = Provider.of<AuthController>(context, listen: false).user?.uid;
    Provider.of<DiaryController>(context, listen: false).syncUnsyncedNotes(userId ?? 'guest');

    super.initState();
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(title: Text('Diary')),
      body: Consumer<DiaryController>(
        builder: (_, diaryController, __) {
            return CustomScrollView(slivers: [
              SliverAppBar(
                backgroundColor: Colors.blue,
                floating: true,
                pinned: false,
                snap: true,
                collapsedHeight: 80,
                expandedHeight: 80,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Container(
                    width: double.infinity,
                    height: 50,
                    color: Colors.blue,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 20,
                      color: Colors.white,
                      child: Center(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 6,
                              child: TextField(
                                textInputAction: TextInputAction.go,
                                onChanged: (String value)=> diaryController.filterNotes(queryText: value, userId: userId),
                                style: const TextStyle(fontSize: 12, color: Colors.black),
                                decoration: InputDecoration(
                                  hintText: "Search Diary",
                                  hintStyle: const TextStyle(color: Colors.black38, fontSize: 12),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only( left: 10, bottom: 5),
                                ),
                              ),
                            ),
                            const Expanded(
                              flex: 1,
                              child: Icon(
                                Icons.search,
                                color: Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (diaryController.notes.isEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                      height: 400,
                      child: Center(
                        child: Text(
                          'No Diary Available',
                          style: const TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                )
              else
                SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    childCount: diaryController.notes.length,
                        (BuildContext context, int index) {
                      var diary = diaryController.notes[index];

                      return Card(
                        elevation: 10,
                        shadowColor: Colors.blue,
                        margin: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    ///todo - need to delete note here
                                    // diaryController
                                    //     .delete(task.id);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    diary.noteName,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Divider(height: 5,thickness: 1,color: Theme.of(context).primaryColor),
                                  const SizedBox(height: 10),

                                  Text(
                                    diary.note,
                                    maxLines: 3,
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                ),
            ]);
          },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String noteName = 'note name';
          String note = 'Sample note content';
          await Provider.of<DiaryController>(context, listen: false).saveNote(userId ?? '', noteName, note);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}