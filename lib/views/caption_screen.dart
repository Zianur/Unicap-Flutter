import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:unicap_cg/common/basewidgets/icon_text_widget.dart';
import 'package:unicap_cg/controllers/auth_controller.dart';
import 'package:unicap_cg/controllers/fav_caption_controller.dart';
import 'package:unicap_cg/models/caption_category.dart';
import '../controllers/caption_category_controller.dart';

class CaptionScreen extends StatefulWidget {
  final CaptionCategory category;
  const CaptionScreen({super.key, required this.category});

  @override
  _CaptionScreenState createState() => _CaptionScreenState();
}

class _CaptionScreenState extends State<CaptionScreen> {
  String? userId;

  @override
  void initState() {
    super.initState();

    final AuthController authController = Provider.of<AuthController>(context, listen: false);
    userId = authController.user?.uid;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: CustomScrollView(slivers: [
        Consumer<CaptionCategoryController>(
            builder: (_, captionCategoryController, __) {
              return SliverAppBar(
                automaticallyImplyLeading: false, // Removes back button
                backgroundColor: Theme.of(context).primaryColor,
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
                    color: Theme.of(context).primaryColor,
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
                                // onChanged: (String value)=> captionCategoryController.filterNotes(queryText: value, userId: userId ?? 'guest'),
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

        Consumer<CaptionCategoryController>(
            builder: (_, captionCategoryController, __) {
              return widget.category.captions != null ? (widget.category.captions?.isNotEmpty ?? false)
                  ? SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  sliver: SliverList.separated(
                    itemCount: widget.category.captions?.length,
                    itemBuilder: (context, index){
                      return _CaptionWidget(caption: widget.category.captions![index], index: index);
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
              ) : SliverToBoxAdapter(child: _CaptionCardShimmer());
            }
        ),
      ]),
    );
  }
}

class _CaptionWidget extends StatelessWidget {
  const _CaptionWidget({
    required this.caption,
    required this.index,
  });

  final Caption caption;
  final int index;

  @override
  Widget build(BuildContext context) {
    final widthSize = MediaQuery.sizeOf(context).width;

    final AuthController authController = Provider.of<AuthController>(context, listen: false);
    final String userId = authController.user?.uid ?? '';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5), // No rounded corners
      ),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(
              width: widthSize,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(caption.caption, style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ), textAlign: TextAlign.center),
            ),
            SizedBox(height: 10),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              IconTextWidget(onTap: (){}, icon: Icons.copy, text: 'Copy'),

              IconTextWidget(
                  onTap: (){
                   Provider.of<FavoriteCaptionController>(context, listen: false).addFavorite(userId, caption);
                  },
                  icon: Icons.favorite, text: 'Favorite',
              ),

              IconTextWidget(onTap: (){}, icon: Icons.share, text: 'Share'),
            ])
          ],
        ),
      ),
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
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                alignment: Alignment.center,
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
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

