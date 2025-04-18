import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:unicap_cg/common/basewidgets/custom_toast_message.dart';
import 'package:unicap_cg/common/basewidgets/icon_text_widget.dart';
import 'package:unicap_cg/controllers/auth_controller.dart';
import 'package:unicap_cg/controllers/fav_caption_controller.dart';
import 'package:unicap_cg/models/fav_caption.dart';

class FavCaptionWidget extends StatelessWidget {
  const FavCaptionWidget({super.key,
    required this.caption,
    required this.index,
  });

  final FavoriteCaption caption;
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
                    Clipboard.setData(ClipboardData(text: caption.caption));
                  },
                  icon: Icons.copy,
                  text: 'Copy',
              ),

              IconTextWidget(
                onTap: (){
                  Provider.of<FavoriteCaptionController>(context, listen: false).removeFavorite(userId, caption.captionId);
                  CustomToast.showToast('Removed from favorites successfully', ToastType.success, null);
                },
                icon: Icons.favorite,
                text: 'Favorite',
                iconColor: isFav ? Colors.pink : null,
                textStyle: isFav ? TextStyle(color: Colors.pink) : null,
              ),

              IconTextWidget(onTap: ()=> Share.share(caption.caption), icon: Icons.share, text: 'Share'),
            ])
          ],
        ),
      ),
    );
  }
}