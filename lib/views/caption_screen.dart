import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:unicap_cg/common/basewidgets/caption_widget.dart';
import 'package:unicap_cg/common/basewidgets/empty_widget.dart';
import 'package:unicap_cg/controllers/auth_controller.dart';
import 'package:unicap_cg/controllers/fav_caption_controller.dart';
import 'package:unicap_cg/models/caption_category.dart';
import '../controllers/caption_category_controller.dart';

class CaptionScreen extends StatefulWidget {
  final CaptionCategory category;
  const CaptionScreen({super.key, required this.category});

  @override
  CaptionScreenState createState() => CaptionScreenState();
}

class CaptionScreenState extends State<CaptionScreen> {
  late String userId;

  @override
  void initState() {
    super.initState();

    loadData();

    // Future.delayed(Duration.zero, () async {
    //   await loadData();
    // });

  }

  Future<void> loadData() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    authController.getCurrentUser();
    userId = authController.user?.uid ?? 'guest';
    debugPrint('=========caption screen=========userid======================$userId');

    await Provider.of<CaptionCategoryController>(context, listen: false).getCaptions(widget.category);
    await Provider.of<FavoriteCaptionController>(context, listen: false).getAllFavCaptionsFromLocal(userId);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          Consumer<CaptionCategoryController>(
              builder: (_, captionCategoryController, __) {
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
                                  onChanged: (String value)=> captionCategoryController.filterCaptions(queryText: value, category: widget.category),
                                  style: const TextStyle(fontSize: 12, color: Colors.black),
                                  decoration: InputDecoration(
                                    hintText: "Search Captions with Keywords",
                                    hintFadeDuration: Duration(milliseconds: 500),
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
                return captionCategoryController.captions != null ? (captionCategoryController.captions?.isNotEmpty ?? false)
                    ? SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    sliver: SliverList.separated(
                      itemCount: captionCategoryController.captions?.length,
                      itemBuilder: (context, index){
                        return CaptionWidget(caption: captionCategoryController.captions![index], index: index, userId: userId);
                      },
                      separatorBuilder: (_, index)=> SizedBox(height: 10),
                    )
                ) : SliverToBoxAdapter(
                  child: EmptyWidget(),
                ) :  SliverToBoxAdapter(
                    child: ListView.builder(
                      itemCount: 10,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return _CaptionCardShimmer();
                      },
                    ));
              }
          ),
        ]),
      ),
    );
  }
}


class _CaptionCardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
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
      ),
    );
  }
}

