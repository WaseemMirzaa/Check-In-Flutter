import 'package:check_in/controllers/group_detail_controller.dart';
import 'package:check_in/controllers/group_members_controller.dart';
import 'package:check_in/ui/screens/%20Messages%20and%20Groupchat/Group%20Detail/Widgets/textfields.dart';
import 'package:check_in/ui/screens/%20Messages%20and%20Groupchat/Group%20Members/group_members.dart';
import 'package:check_in/ui/widgets/common_button.dart';
import 'package:check_in/ui/widgets/custom_appbar.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

import 'Widgets/bottomsheet.dart';

class GroupdetailScreen extends GetView<UsergroupDetailController> {
  String? docId;
  GroupdetailScreen({super.key, this.docId});
  var groupmemberController = Get.find<GroupmemberController>();
  @override
  Widget build(BuildContext context) {
    controller.getGroupDetail(docId!);
    return Scaffold(
      appBar: CustomAppbar(
        title: poppinsText('Group Details', 20, bold, blackColor),
        actions: [
          GestureDetector(
              onTap: () {
                groupmemberController.docid = docId!;
                pushNewScreen(context, screen: const GroupMember());
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: SvgPicture.asset(AppImage.peopleicon),
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  verticalGap(40),
                  const NameTextfield(),
                  verticalGap(26),
                  SizedBox(
                    width: 130,
                    height: 135,
                    child: Stack(
                      children: [
                        const CircleAvatar(
                          backgroundImage: NetworkImage(
                              'https://wac-cdn.atlassian.com/dam/jcr:ba03a215-2f45-40f5-8540-b2015223c918/Max-R_Headshot%20(1).jpg?cdnVersion=1365'),
                          radius: 65,
                        ),
                        Positioned(
                          right: 10,
                          bottom: 1,
                          child: GestureDetector(
                            onTap: () {
                              showbottomSheet(context);
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: const BoxDecoration(
                                  color: greenColor, shape: BoxShape.circle),
                              child: const Icon(
                                Icons.camera_alt,
                                color: white,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  verticalGap(60),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        poppinsText('About Group', 14, semiBold, blackColor),
                        GestureDetector(
                          onTap: () {
                            controller.aboutfocusNode.requestFocus();
                          },
                          child: SvgPicture.asset(
                            AppImage.penicon,
                            height: 17,
                            width: 17,
                          ),
                        )
                      ],
                    ),
                  ),
                  verticalGap(5),
                  const Divider(thickness: 2),
                  const AboutTextfield()
                ],
              ),
            )),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: fullWidthButton('Save', () {
                controller.updateGroupDetail(docId!);
              }),
            )
          ],
        ),
      ),
    );
  }
}
