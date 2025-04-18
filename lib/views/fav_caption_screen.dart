import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:unicap_cg/common/basewidgets/caption_widget.dart';
import 'package:unicap_cg/common/basewidgets/fav_caption_widget.dart';
import 'package:unicap_cg/common/basewidgets/icon_text_widget.dart';
import 'package:unicap_cg/controllers/auth_controller.dart';
import 'package:unicap_cg/controllers/fav_caption_controller.dart';
import 'package:unicap_cg/models/caption_category.dart';
import 'package:unicap_cg/models/fav_caption.dart';
import '../controllers/caption_category_controller.dart';

class FavCaptionScreen extends StatefulWidget {
  const FavCaptionScreen({super.key});

  @override
  _FavCaptionScreenState createState() => _FavCaptionScreenState();
}

class _FavCaptionScreenState extends State<FavCaptionScreen> {
  String? userId;
  @override
  void initState() {
    super.initState();


    /// Get FavCaptions
    final AuthController authController = Provider.of<AuthController>(context, listen: false);

    if(authController.isLoggedIn){
      userId = authController.user?.uid;
      debugPrint('==============user id========${authController.user?.uid}');

      Provider.of<FavoriteCaptionController>(context, listen: false).syncUnsyncedFavCaptions(userId ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: CustomScrollView(slivers: [
        Consumer<FavoriteCaptionController>(
            builder: (_, favCaptionController, __) {
              return SliverAppBar(
                automaticallyImplyLeading: false, // Removes back button
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
                                /// todo - need to update this
                                onChanged: (String value)=> favCaptionController.filterFavCaption(queryText: value, userId: userId ?? 'guest'),
                                style: const TextStyle(fontSize: 12, color: Colors.black),
                                decoration: InputDecoration(
                                  hintText: "Search Favorite Captions with Keywords",
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

        Consumer<FavoriteCaptionController>(
            builder: (_, favCaptionController, __) {
              return favCaptionController.favorites != null ? (favCaptionController.favorites?.isNotEmpty ?? false)
                  ? SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  sliver: SliverList.separated(
                    itemCount: favCaptionController.favorites?.length,
                    itemBuilder: (context, index){
                      return FavCaptionWidget(caption: favCaptionController.favorites![index], index: index);
                    },
                    separatorBuilder: (_, index)=> SizedBox(height: 10),
                  )
              ) : SliverToBoxAdapter(
                child: SizedBox(
                    height: 400,
                    child: Center(
                      child: Text(
                        'No Category Available',
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ) : SliverToBoxAdapter(
                  child: ListView.builder(
                    itemCount: 10,
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    itemBuilder: (context, index) {
                      return _CaptionCardShimmer();
                    },
                  ));
            }
        ),
      ]),
    );
  }
}

class _CaptionCardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Shimmering Caption Box
            Shimmer.fromColors(
              baseColor: Colors.grey[500]!,
              highlightColor: Colors.grey[200]!,
              child: Container(
                alignment: Alignment.center,
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
            SizedBox(height: 5),

            // Shimmering Icons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 24,
                    height: 24,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

