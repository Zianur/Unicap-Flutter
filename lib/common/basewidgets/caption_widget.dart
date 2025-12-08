import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:unicap_cg/common/basewidgets/custom_toast_message.dart';
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
          debugPrint('=============isFav=====================$isFav');

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

                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Expanded(
                      child: IconTextWidget(
                        onTap: (){
                          CustomToast.showToast('Caption Copied', ToastType.success, null);
                          Clipboard.setData(ClipboardData(text: caption.caption));
                        }  ,
                        icon: Icons.copy,
                      ),
                    ),

                    Expanded(
                      child: IconTextWidget(
                        isLoading: isLoading(favCaptionController),
                        onTap: () async{
                          if(!isFav){
                            debugPrint('============Inside ontap=========');
                            await favCaptionController.addFavorite(userId, caption);
                            CustomToast.showToast('Added to the Favorite', ToastType.fav, null);
                          }
                          else{
                            debugPrint('==================inside else=============$isFav');
                            await favCaptionController.removeFavorite(userId, caption.key);
                            CustomToast.showToast('Removed from favorites successfully', ToastType.success, null);
                          }
                        },
                        icon: Icons.favorite,
                        iconColor: isFav ? Colors.pink : null,
                        textStyle: isFav ? TextStyle(color: Colors.pink) : null,
                      ),
                    ),

                    Expanded(child: IconTextWidget(
                      onTap: (){

                      },
                      icon: Icons.image,
                    )),

                    Expanded(child: IconTextWidget(
                      onTap: (){

                      },
                      icon: Icons.translate,
                    )),

                    Expanded(child: IconTextWidget(onTap: ()=> Share.share(caption.caption), icon: Icons.share)),
                  ])
                ],
              ),
            ),
          );
        }
    );
  }

  bool isLoading(FavoriteCaptionController favCaptionController) => favCaptionController.isLoading && favCaptionController.captionKey == caption.key;
}