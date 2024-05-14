import 'package:check_in/controllers/Messages/chat_controller.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/utils/DateTimeUtils.dart';
import 'package:check_in/utils/loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../model/Message and Group Message Model/chat_model.dart';
import '../../../../../utils/colors.dart';
import '../../../../../utils/gaps.dart';
import '../../../../../utils/styles.dart';

// ignore: must_be_immutable
class ImageDateContainer extends StatefulWidget {
  // int? index;
  Chatmodel? chat;
  bool? mymsg;
  bool? showLastSeen;

  bool? isGroup;
  ImageDateContainer(
      {super.key,
      this.chat,
      this.mymsg,
      this.showLastSeen,
      this.isGroup});

  @override
  State<ImageDateContainer> createState() => _ImageDateContainerState();
}

class _ImageDateContainerState extends State<ImageDateContainer> {
  final chatController = Get.find<ChatController>();

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   setState(() {
  //
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    //String timeseperate = widget.chat!.time!.toString().split(' ')[1];
    //String timeseperate = widget.chat!.time!.toString().split(' ')[1];
    String time = DateTimeUtils.timeStamp24to12(widget.chat!.time!);
    return Column(
      crossAxisAlignment: widget.mymsg! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: widget.chat!.isDelete == true
              ? null
              : () {
                  showGeneralDialog(
                      barrierColor: greyColor,
                      context: context,
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 17.0, vertical: 50),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: appWhiteColor,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 40.0),
                              child: Image.network(
                                widget.chat!.message!,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: whiteColor,
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 80,
                            ),
                          ],
                        );
                      });
                },
          onLongPress: widget.mymsg! && widget.chat!.isDelete == null || widget.chat!.isDelete == false
              ? () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text(
                              'Delete Message',
                              style: TextStyle(fontWeight: FontWeight.w600, color: appBlackColor),
                            ),
                            content: Text('Do you want to delete this message?',
                                style: TextStyle(fontWeight: FontWeight.w400, color: appBlackColor, fontSize: 14)),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('No')),
                              TextButton(
                                  onPressed: () async {
                                    await chatController
                                        .deleteMessage(chatController.docId.value, widget.chat!.docID!)
                                        .then((value) => Navigator.pop(context));
                                  },
                                  child: const Text('Yes'))
                            ],
                          ));
                }
              : null,
          child: widget.chat!.isDelete == true
              ? Container(
                  constraints: BoxConstraints(maxWidth: 65.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: widget.chat!.isDelete == true
                        ? greyColor.withOpacity(0.3)
                        : widget.mymsg!
                            ? appGreenColor
                            : greyColor1.withOpacity(1),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    widget.chat!.message!,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                          fontStyle: widget.chat!.isDelete == true ? FontStyle.italic : null,
                          color: widget.chat!.isDelete == true
                              ? appWhiteColor
                              : widget.mymsg!
                                  ? appWhiteColor
                                  : greyColor.withOpacity(1)),
                    ),
                  ),
                )
              : Container(
                  height: 200,
                  width: 40.w,
                  decoration: BoxDecoration(
                      color: appGreenColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: appGreenColor, width: 2)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: widget.chat!.message!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => loaderView(loaderColor: whiteColor),
                    ),
                  ),
                ),
        ),
        verticalGap(8),
        Row(
          children: [
            poppinsText(time, 10, medium, greyColor.withOpacity(1)),
            horizontalGap(5),
            widget.chat!.isDelete !=true && widget.isGroup != true && widget.mymsg! && widget.chat!.isRead != true  ? Icon(Icons.check,size: 15,color: greyColor,) : widget.chat!.isDelete !=true && widget.isGroup != true && widget.mymsg! && widget.chat!.isRead == true ? const ImageIcon(AssetImage(AppAssets.DOUBLE_TICK),size: 15,color: greenColor) : const SizedBox(),

            // mymsg!
            //     ? poppinsText('✓', 10, medium, greyColor.withOpacity(1))
            //     : const SizedBox(),
            // horizontalGap(5),
            // mymsg!
            //     ? const CircleAvatar(
            //         backgroundImage: CachedNetworkImageProvider(
            //             'https://wac-cdn.atlassian.com/dam/jcr:ba03a215-2f45-40f5-8540-b2015223c918/Max-R_Headshot%20(1).jpg?cdnVersion=1365'),
            //         radius: 8,
            //       )
            //     : const SizedBox()
          ],
        ),
        // widget.chat!.seenTimeStamp != '' && widget.showLastSeen == true && widget.isGroup == false
        //     ? Container(
        //         padding: const EdgeInsets.all(5),
        //         decoration: BoxDecoration(
        //           border: Border.all(),
        //           borderRadius: BorderRadius.circular(15),
        //         ),
        //         child: poppinsText("Seen ${widget.seenTime}", 9, medium, greyColor),
        //       )
        //     : const SizedBox()
      ],
    );
  }
}
