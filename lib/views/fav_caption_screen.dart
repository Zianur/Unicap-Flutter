import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:unicap_cg/common/basewidgets/empty_widget.dart';
import 'package:unicap_cg/common/basewidgets/fav_caption_widget.dart';
import 'package:unicap_cg/controllers/auth_controller.dart';
import 'package:unicap_cg/controllers/fav_caption_controller.dart';

class FavCaptionScreen extends StatefulWidget {
  const FavCaptionScreen({super.key});

  @override
  FavCaptionScreenState createState() => FavCaptionScreenState();
}

class FavCaptionScreenState extends State<FavCaptionScreen> {
  String userId = 'guest';



  @override
  void initState() {
    super.initState();

    loadData();

    // Future.delayed(Duration.zero, () async {
    //   loadData();
    // });

  }

  void loadData() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    authController.getCurrentUser();
    userId = authController.user?.uid ?? 'guest';

    debugPrint('=========fav caption screen=========userid======================$userId');

    await Provider.of<FavoriteCaptionController>(context, listen: false).syncUnsyncedFavCaptions(userId);
  }

  @override
  Widget build(BuildContext context) {

    return CustomScrollView(slivers: [
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
                              onChanged: (String value)=> favCaptionController.filterFavCaption(queryText: value, userId: userId),
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
                    return FavCaptionWidget(caption: favCaptionController.favorites![index], index: index, userId: userId);
                  },
                  separatorBuilder: (_, index)=> SizedBox(height: 10),
                )
            ) : SliverToBoxAdapter(
              child: EmptyWidget(),
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
    ]);
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

