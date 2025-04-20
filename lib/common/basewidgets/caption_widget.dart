import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicap_cg/common/basewidgets/icon_text_widget.dart';
import 'package:unicap_cg/controllers/auth_controller.dart';
import 'package:unicap_cg/controllers/fav_caption_controller.dart';
import 'package:unicap_cg/models/caption_category.dart';

class CaptionWidget extends StatelessWidget {
  const CaptionWidget({super.key,
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
    final FavoriteCaptionController favoriteCaptionController = Provider.of<FavoriteCaptionController>(context);

    final bool isFav = favoriteCaptionController.isCaptionFavorite(caption.caption);

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
              IconTextWidget(
                onTap: (){

                },
                icon: Icons.copy,
                text: 'Copy',
              ),

              IconTextWidget(
                onTap: (){
                  print('==================isFav=============$isFav');

                  if(!isFav){
                    print('============Inside ontap=========');
                    Provider.of<FavoriteCaptionController>(context, listen: false).addFavorite(userId, caption);
                  }
                  else{
                    print('==================inside else=============$isFav');
                    Provider.of<FavoriteCaptionController>(context, listen: false).removeFavorite(userId, caption.caption);
                  }
                },
                icon: Icons.favorite,
                text: 'Favorite',
                iconColor: isFav ? Colors.pink : null,
                textStyle: isFav ? TextStyle(color: Colors.pink) : null,
              ),

              IconTextWidget(onTap: (){}, icon: Icons.share, text: 'Share'),
            ])
          ],
        ),
      ),
    );
  }
}