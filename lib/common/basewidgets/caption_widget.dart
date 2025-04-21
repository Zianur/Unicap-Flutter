import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicap_cg/common/basewidgets/icon_text_widget.dart';
import 'package:unicap_cg/controllers/fav_caption_controller.dart';
import 'package:unicap_cg/models/caption_category.dart';

class CaptionWidget extends StatelessWidget {
  const CaptionWidget({super.key,
    required this.caption,
    required this.index,
    required this.userId,
  });

  final Caption caption;
  final int index;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final widthSize = MediaQuery.sizeOf(context).width;

    return Consumer<FavoriteCaptionController>(
      builder: (context, favCaptionController, _) {
        final bool isFav = favCaptionController.isCaptionFavorite(caption.caption);
        print('=============isFav=====================$isFav');

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

                      if(!isFav){
                        print('============Inside ontap=========');
                        Provider.of<FavoriteCaptionController>(context, listen: false).addFavorite(userId, caption);
                      }
                      else{
                        print('==================inside else=============$isFav');
                        Provider.of<FavoriteCaptionController>(context, listen: false).removeFavorite(userId, caption.key);
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
    );
  }
}