// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:check_in/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import '../../../../../controllers/Messages/messages_controller.dart';
import '../../../../../model/Message and Group Message Model/message_model.dart';
import '../../../../../utils/Constants/images.dart';
import '../../../../../utils/DateTimeUtils.dart';
import '../../../../../utils/colors.dart';
import '../../../../../utils/gaps.dart';
import '../../../../../utils/styles.dart';

class MessageListTile extends StatefulWidget {
  Messagemodel? message;
  Function()? ontap;
  MessageListTile({super.key, this.message, this.ontap});

  @override
  State<MessageListTile> createState() => _MessageListTileState();
}

class _MessageListTileState extends State<MessageListTile> {
  var messageController = Get.find<MessageController>();

  @override
  void initState() {
    super.initState();
    // widget.message!.deleteIds?.forEach((element) {
    //   if (element['uid'] == userController.userModel.value.uid) {
    //     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //       if (!element['isDeleted']) {
    //         setState(() {
    //           widget.message = widget.message?.copyWith(lastmessage: '');
    //         });
    //       }
    //     });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
   // String dateseperate = message!.timeStamp == null ? '' : message!.timeStamp!.toString().split(' ')[1];
    String time = widget.message!.timeStamp == null ? '' : DateTimeUtils.timeStamp24to12(widget.message!.timeStamp!);

    String unReadCount = widget.message!.unreadmsg! < 10 ? '0${widget.message!.unreadmsg.toString()}' : widget.message!.unreadmsg.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: widget.ontap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            height: 78,
            // width: 50,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: appGreenColor.withOpacity(0.6),
                  backgroundImage: widget.message!.image! == ''
                      ? AssetImage(AppImage.user) as ImageProvider
                      : CachedNetworkImageProvider(widget.message!.image!),
                  radius: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (widget.message!.isgroup!) ...[
                            SvgPicture.asset(
                              AppImage.chatgroupicon,
                            ),
                            horizontalGap(8)
                          ],
                          SizedBox(
                            width: 45.w,
                            child:
                                poppinsText(widget.message!.name!, 15, medium, appBlackColor, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      FutureBuilder<String?>(
                        future: messageController.getLastMessage(widget.message?.id ?? ''),
                        builder: (_, snap){
                          if(snap.hasData && snap.data != null) {
                            return SizedBox(
                              width: 45.w,
                              child: poppinsText(
                                (snap.data ?? '').contains('https://') ? 'Photo' : (snap.data ?? ''),
                                12,
                                medium,
                                appBlackColor.withOpacity(0.65),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    widget.message!.unreadmsg == 0
                        ? SizedBox(
                            height: 3.h,
                          )
                        : Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: appGreenColor, shape: BoxShape.circle),
                            child: poppinsText(
                              unReadCount,
                              9,
                              FontWeight.normal,
                              appWhiteColor,
                            ),
                          ),
                    poppinsText(time, 10, FontWeight.normal, const Color(0xFF161F3D).withOpacity(0.4))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
