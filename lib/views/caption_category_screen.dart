import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:unicap_cg/common/basewidgets/color_animated_text.dart';
import 'package:unicap_cg/common/basewidgets/diary_shimmer.dart';
import 'package:unicap_cg/controllers/caption_category_controller.dart';
import 'package:unicap_cg/models/caption_category.dart';
import 'package:unicap_cg/views/caption_screen.dart';

class CaptionCategoryView extends StatefulWidget {
  const CaptionCategoryView({super.key});

  @override
  State<CaptionCategoryView> createState() => _CaptionCategoryState();
}

class _CaptionCategoryState extends State<CaptionCategoryView> {
  @override
  Widget build(BuildContext context) {

    return CustomScrollView(slivers: [
      Consumer<CaptionCategoryController>(
          builder: (_, captionCategoryController, __) {
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
                              onChanged: (String value)=> captionCategoryController.filterCategories(queryText: value),
                              style: const TextStyle(fontSize: 12, color: Colors.black),
                              decoration: InputDecoration(
                                hintText: "Search Caption Category with Keywords",
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
            return captionCategoryController.categories != null ? (captionCategoryController.categories?.isNotEmpty ?? false)
                ? SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2, // Number of columns
                mainAxisSpacing: 8, // Vertical spacing
                crossAxisSpacing: 8, // Horizontal spacing
                childCount: captionCategoryController.categories?.length,
                itemBuilder: (context, index){
                  CaptionCategory? category = captionCategoryController.categories?[index];

                  return _CategoryWidget(category: category!, index: index);
                },
              ),
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
            ) : SliverToBoxAdapter(child: DiaryShimmer());
          }
      ),
    ]);
  }
}

class _CategoryWidget extends StatelessWidget {
  const _CategoryWidget({
    required this.category,
    required this.index,
  });

  final CaptionCategory category;
  final int index;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: ()=> Navigator.push(context,
          MaterialPageRoute(builder: (context)=> CaptionScreen(category: category)),
      ),
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
      
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.black, width: 2)
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CachedNetworkImage(
                    imageUrl: category.imageUrl ?? '',
                    placeholder: (context, url) => Center(
                      child: Icon(Icons.image),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                    fit: BoxFit.cover,
                    height: 70,
                    width: 70,
                  ),
                ),
              ),
      
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Divider(height: 5,thickness: 1, color: Theme.of(context).disabledColor),
              ),
      
              ColorAnimatedText(text: category.name ?? ''),
            ],
          ),
        ),
      ),
    );
  }
}

