import 'package:check_in/controllers/group_members_controller.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/group_member_model.dart';
import 'package:check_in/ui/screens/%20Messages%20and%20Groupchat/Group%20Members/Widgets/group_member_tile.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sizer/sizer.dart';
import '../../../../utils/loader.dart';
import '../../../../utils/styles.dart';
import '../../../widgets/custom_appbar.dart';
import '../Messages/Widgets/search_field.dart';

class GroupMember extends GetView<GroupmemberController> {
  const GroupMember({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppImage.peopleicon,
              color: black,
            ),
            horizontalGap(10),
            poppinsText('Group Members', 15, bold, blackColor)
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalGap(15),
          StreamBuilder<List<GroupMemberModel>>(
              stream: controller.getGroupMember(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return loaderView();
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: poppinsText("${snapshot.data!.length} Members", 22,
                        bold, blackColor),
                  );
                }
              }),
          verticalGap(10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SearchField(
              onchange: (query) {
                controller.searchQuery.value = query;
              },
            ),
          ),
          verticalGap(15),
          Expanded(
            child: SizedBox(
                height: 60.h,
                child: StreamBuilder<List<GroupMemberModel>>(
                    stream: controller.getGroupMember(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return loaderView();
                      } else if (!snapshot.hasData) {
                        return const Center(child: Text('No members found.'));
                      } else {
                        return ListView.separated(
                          itemCount: snapshot.data!.length,
                          separatorBuilder: (context, index) {
                            return verticalGap(10);
                          },
                          itemBuilder: (context, index) {
                            return Obx(() {
                              if (snapshot.data![index].memberName!
                                  .toLowerCase()
                                  .contains(
                                      controller.searchQuery.toLowerCase())) {
                                return GroupMemberTile(
                                  data: snapshot.data![index],
                                  ontap: (_) {
                                    print('object');
                                    if (snapshot.data![index].iAmAdmin!) {
                                      if (!snapshot.data![index].isAdmin!) {
                                        controller.makeGroupAdmin(
                                            snapshot.data![index].memberId!);
                                      }
                                    }
                                  },
                                );
                              } else {
                                return Container();
                              }
                            });
                          },
                        );
                      }
                    })),
          )
        ],
      ),
    );
  }
}
