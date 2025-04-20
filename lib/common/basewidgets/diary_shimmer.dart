
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

class DiaryShimmer extends StatelessWidget {
  const DiaryShimmer({super.key});

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