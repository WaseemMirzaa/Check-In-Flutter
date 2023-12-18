import 'package:check_in/ui/screens/%20Messages%20and%20Groupchat/Chat/chat_screen.dart';
import 'package:check_in/ui/widgets/custom_appbar.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

import '../../../../utils/styles.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton(),
      appBar: appBar(),
      body: Column(
        children: [searchTextfield(), verticalGap(20), chatListview()],
      ),
    );
  }

  Widget floatingActionButton() {
    return FloatingActionButton.extended(
      backgroundColor: greenColor,
      label: Row(
        children: [
          poppinsText('Send message', 12, FontWeight.normal, white),
          horizontalGap(35),
          SvgPicture.asset(
            AppImage.messageappbaricon,
            color: whiteColor,
          ),
        ],
      ),
      onPressed: () {},
    );
  }

  PreferredSizeWidget appBar() {
    return CustomAppbar(
      showicon: false,
      title: Row(mainAxisSize: MainAxisSize.min, children: [
        SvgPicture.asset(AppImage.messageappbaricon),
        horizontalGap(15),
        poppinsText('Messages', 20, FontWeight.bold, blackColor)
      ]),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: SvgPicture.asset(
            AppImage.messagecircle,
          ),
        )
      ],
    );
  }

  Widget searchTextfield() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(40),
        child: TextFormField(
          decoration: InputDecoration(
              hintText: 'Search',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(40),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(40),
              ),
              suffixIcon: const Icon(Icons.search)),
        ),
      ),
    );
  }

  Widget chatListview() {
    return Expanded(
      child: ListView.separated(
          padding: const EdgeInsets.only(top: 14, bottom: 70),
          separatorBuilder: (_, __) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Divider(
                indent: 20,
                endIndent: 20,
                thickness: 2,
              ),
            );
          },
          itemCount: 10,
          itemBuilder: (context, builder) {
            return chatListtile(context);
          }),
    );
  }

  Widget chatListtile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(6),
        child: GestureDetector(
          onTap: () {
            pushNewScreen(context, screen: const ChatScreen());
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            height: 78,
            width: 50,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://wac-cdn.atlassian.com/dam/jcr:ba03a215-2f45-40f5-8540-b2015223c918/Max-R_Headshot%20(1).jpg?cdnVersion=1365'),
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
                          SvgPicture.asset(
                            AppImage.chatgroupicon,
                          ),
                          horizontalGap(8),
                          poppinsText('Basket ball group', 15, FontWeight.bold,
                              blackColor),
                        ],
                      ),
                      poppinsText('Lorel Ipsum', 12, FontWeight.bold,
                          blackColor.withOpacity(0.65))
                    ],
                  ),
                ),
                const Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: greenColor, shape: BoxShape.circle),
                      child: poppinsText(
                        '03',
                        9,
                        FontWeight.normal,
                        whiteColor,
                      ),
                    ),
                    poppinsText('5 : 45 PM', 10, FontWeight.normal,
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
