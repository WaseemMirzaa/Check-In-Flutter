import 'package:check_in/ui/screens/%20Messages%20and%20Groupchat/Group%20Detail/group_detail.dart';
import 'package:check_in/ui/widgets/custom_appbar.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/gaps.dart';
import '../../../../utils/styles.dart';
import '../../../widgets/custom_textfield.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 10),
                  reverse: true,
                  itemCount: 20,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 2 ? 0 : 14,
                        right: index == 2 ? 14 : 0,
                        top: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: index == 2
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          index == 2
                              ? const SizedBox()
                              : const CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      'https://wac-cdn.atlassian.com/dam/jcr:ba03a215-2f45-40f5-8540-b2015223c918/Max-R_Headshot%20(1).jpg?cdnVersion=1365'),
                                  radius: 17,
                                ),
                          horizontalGap(8),
                          messageandDateContainer(index)
                        ],
                      ),
                    );
                  })),
          sendMessageContainer()
        ],
      ),
    );
  }

  PreferredSizeWidget appBar(BuildContext context) {
    return CustomAppbar(
      title: GestureDetector(
        onTap: () {
          pushNewScreen(context, screen: const GroupdetailScreen());
        },
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const CircleAvatar(
            backgroundImage: NetworkImage(
                'https://wac-cdn.atlassian.com/dam/jcr:ba03a215-2f45-40f5-8540-b2015223c918/Max-R_Headshot%20(1).jpg?cdnVersion=1365'),
            radius: 20,
          ),
          horizontalGap(15),
          SvgPicture.asset(AppImage.chatgroupicon),
          horizontalGap(5),
          poppinsText('Anothoney Joseph', 15, FontWeight.bold, blackColor)
        ]),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: SvgPicture.asset(AppImage.callicon),
        )
      ],
    );
  }

  Widget messageandDateContainer(int index) {
    return Column(
      crossAxisAlignment:
          index == 2 ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            index == 2
                ? const SizedBox()
                : CustomPaint(
                    painter: CustomShape(bgcolor: greyColor1.withOpacity(1)),
                  ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(15),
                    topRight: const Radius.circular(15),
                    bottomLeft: Radius.circular(index == 2 ? 15 : 0),
                    bottomRight: Radius.circular(index == 2 ? 0 : 15)),
                color: index == 2 ? greenColor : greyColor1.withOpacity(1),
              ),
              padding: const EdgeInsets.all(15),
              width: 230,
              child: poppinsText(
                  'Hi Cassie! Would you be available for a coffee next week? ',
                  12,
                  FontWeight.normal,
                  index == 2 ? whiteColor : greyColor.withOpacity(1)),
            ),
            index == 2
                ? CustomPaint(
                    painter: CustomShape(bgcolor: greenColor),
                  )
                : const SizedBox()
          ],
        ),
        verticalGap(8),
        Row(
          children: [
            poppinsText('8:11', 10, medium, greyColor.withOpacity(1)),
            horizontalGap(5),
            index == 2
                ? poppinsText('✓', 10, medium, greyColor.withOpacity(1))
                : const SizedBox(),
            horizontalGap(5),
            index == 2
                ? const CircleAvatar(
                    backgroundImage: NetworkImage(
                        'https://wac-cdn.atlassian.com/dam/jcr:ba03a215-2f45-40f5-8540-b2015223c918/Max-R_Headshot%20(1).jpg?cdnVersion=1365'),
                    radius: 8,
                  )
                : const SizedBox()
          ],
        )
      ],
    );
  }

  Widget sendMessageContainer() {
    return Container(
      decoration: BoxDecoration(color: whiteColor, boxShadow: [
        BoxShadow(
          color: greyColor.withOpacity(0.4),
          offset: const Offset(0, -4),
          blurRadius: 10.0,
        ),
      ]),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        children: [
          SvgPicture.asset(AppImage.chatfieldicon),
          horizontalGap(15),
          SvgPicture.asset(AppImage.chatfieldsticker),
          horizontalGap(11),
          Expanded(child: ChatTextfield()),
          horizontalGap(11),
          SvgPicture.asset(AppImage.sendmsgicon),
        ],
      ),
    );
  }
}

class CustomShape extends CustomPainter {
  final Color bgcolor;
  CustomShape({required this.bgcolor});
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = bgcolor;
    var path = Path();
    path.lineTo(-10, 0);
    path.lineTo(0, -10);
    path.lineTo(5, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
