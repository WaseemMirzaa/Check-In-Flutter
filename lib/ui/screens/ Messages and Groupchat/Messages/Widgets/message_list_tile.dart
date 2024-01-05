// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';

import '../../../../../model/message_model.dart';
import '../../../../../utils/Constants/images.dart';
import '../../../../../utils/DateTimeUtils.dart';
import '../../../../../utils/colors.dart';
import '../../../../../utils/gaps.dart';
import '../../../../../utils/styles.dart';

class MessageListTile extends StatelessWidget {
  Messagemodel? message;
  Function()? ontap;
  MessageListTile({super.key, this.message, this.ontap});

  @override
  Widget build(BuildContext context) {
    String dateseperate = message!.timeStamp!.split(' ')[1];
    String time = DateTimeUtils.time24to12(dateseperate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: ontap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            height: 78,
            width: 50,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: greenColor.withOpacity(0.6),
                  backgroundImage: NetworkImage(message!.image! == ''
                      ? AppImage.userImagePath
                      : message!.image!),
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
                          if (message!.isgroup!) ...[
                            SvgPicture.asset(
                              AppImage.chatgroupicon,
                            ),
                            horizontalGap(8)
                          ],
                          SizedBox(
                            width: 45.w,
                            child: poppinsText(
                                message!.name!, 15, FontWeight.bold, blackColor,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 50.w,
                        child: poppinsText(
                          message!.lastmessage!,
                          12,
                          FontWeight.bold,
                          blackColor.withOpacity(0.65),
                        ),
                      )
                    ],
                  ),
                ),
                const Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    message!.unreadmsg == 0
                        ? SizedBox(
                            height: 3.h,
                          )
                        : Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                                color: greenColor, shape: BoxShape.circle),
                            child: poppinsText(
                              "0${message!.unreadmsg.toString()}",
                              9,
                              FontWeight.normal,
                              whiteColor,
                            ),
                          ),
                    poppinsText(time, 10, FontWeight.normal,
                        const Color(0xFF161F3D).withOpacity(0.4))
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
