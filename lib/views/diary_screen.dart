import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:unicap_cg/controllers/auth_controller.dart';
import 'package:unicap_cg/controllers/diary_controller.dart';
import 'package:unicap_cg/models/diary_entry.dart';

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
    print('==============USER ID===================$userId');
    Provider.of<DiaryController>(context, listen: false).syncUnsyncedNotes(userId ?? 'guest');

    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: CustomScrollView(slivers: [
        Consumer<DiaryController>(
          builder: (_, diaryController, __) {
            return SliverAppBar(
              backgroundColor: Colors.deepPurpleAccent,
              floating: true,
              pinned: true,
              snap: true,
              collapsedHeight: 80,
              expandedHeight: 80,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  height: 50,
                  color: Colors.deepPurpleAccent,
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
                              onChanged: (String value)=> diaryController.filterNotes(queryText: value, userId: userId ?? 'guest'),
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
            );
          }
        ),

        Consumer<DiaryController>(
          builder: (_, diaryController, __) {
            return diaryController.notes != null ? (diaryController.notes?.isNotEmpty ?? false)
                ? SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2, // Number of columns
                  mainAxisSpacing: 8, // Vertical spacing
                  crossAxisSpacing: 8, // Horizontal spacing
                  childCount: diaryController.notes?.length,
                  itemBuilder: (context, index){
                    var diary = diaryController.notes?[index];

                    return _DiaryWidget(diary: diary!, index: index);
                  },
                ),
              ) : SliverToBoxAdapter(
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
            ) : _DiaryShimmer();
          }
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String noteName = 'note name';
          String note = 'Sample note content';
          await Provider.of<DiaryController>(context, listen: false).saveNote(userId ?? 'guest', noteName, note);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class _DiaryWidget extends StatelessWidget {
  const _DiaryWidget({
    super.key,
    required this.diary,
    required this.index,
  });

  final DiaryEntry diary;
  final int index;

  @override
  Widget build(BuildContext context) {
    final int noteMaxLines = (index % 2 == 0) ? 3 : 5;

    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              diary.noteName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            SizedBox(height: 5),

            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                diary.note,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withValues(alpha: 0.5)
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: noteMaxLines,
                textAlign: TextAlign.right,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Divider(height: 5,thickness: 1, color: Theme.of(context).disabledColor),
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Text(diary.isSynced ? 'Synced' : 'Unsynced', style: TextStyle(
                  fontSize: 12,
                  color: diary.isSynced ? Colors.green : Colors.red
                )),

                InkWell(
                  onTap: (){},
                  child: Icon(
                    Icons.delete,
                    color: Colors.red.withValues(alpha: 0.8),
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _DiaryShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2, // Number of columns
        mainAxisSpacing: 8, // Vertical spacing
        crossAxisSpacing: 8, // Horizontal spacing
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: index.isEven ? 120 : 160, // Varying height for masonry effect
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        childCount: 10,
      ),
    );
  }
}