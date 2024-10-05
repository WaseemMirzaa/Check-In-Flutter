import 'package:check_in/auth_service.dart';
import 'package:check_in/controllers/Messages/group_members_controller.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/group_member_model.dart';
import 'package:check_in/ui/screens/Messages%20NavBar/Add%20New%20Member/add_new_grp_member.dart';
import 'package:check_in/ui/screens/Messages%20NavBar/Group%20Members/Component/group_member_tile.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';
import '../../../../utils/loader.dart';
import '../../../../utils/styles.dart';
import '../../../widgets/custom_appbar.dart';
import '../Messages/Component/search_field.dart';

class GroupMember extends GetView<GroupmemberController> {
  GroupMember({
    super.key,
    this.isAdmin,
  });
  bool? isAdmin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isAdmin!
          ? FloatingActionButton.extended(
              backgroundColor: greenColor,
              onPressed: () {
                print('dd');
                print(controller.memberIds);
                pushNewScreen(context,
                    screen: AddNewGroupMember(
                        docId: controller.docid,
                        memberIds: controller.memberIds));
              },
              label: poppinsText(
                  TempLanguage.addMember, 12, FontWeight.normal, whiteColor),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: CustomAppbar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppImage.peopleicon,
              color: black,
            ),
            horizontalGap(10),
            poppinsText(TempLanguage.groupMembers, 15, bold, blackColor)
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalGap(15),
          StreamBuilder<List<GroupMemberModel>>(
              stream: controller
                  .getGroupMember(userController.userModel.value.uid!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return loaderView();
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: poppinsText(
                        "${snapshot.data!.length} ${TempLanguage.members}",
                        20,
                        medium,
                        blackColor),
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
                    stream: controller
                        .getGroupMember(userController.userModel.value.uid!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return loaderView();
                      } else if (!snapshot.hasData) {
                        return Center(child: Text(TempLanguage.noMemberFound));
                      } else {
                        return ListView.separated(
                          itemCount: snapshot.data!.length,
                          separatorBuilder: (context, index) {
                            return verticalGap(10);
                          },
                          itemBuilder: (context, index) {
                            log("image is: ${snapshot.data![index].memberImg}");
                            return Obx(() {
                              if (snapshot.data![index].memberName!
                                  .toLowerCase()
                                  .contains(
                                      controller.searchQuery.toLowerCase())) {
                                return GroupMemberTile(
                                  data: snapshot.data![index],
                                  removeMemberOntap: () {
                                    if (snapshot.data![index].iAmAdmin!) {
                                      print('object');
                                      controller.removeGroupMember(
                                        snapshot.data![index].memberId!,
                                      );
                                      Navigator.pop(context);
                                    }
                                  },
                                  ontap: () {
                                    if (snapshot.data![index].iAmAdmin!) {
                                      if (!snapshot.data![index].isAdmin!) {
                                        controller.makeGroupAdmin(
                                            snapshot.data![index].memberId!);
                                      } else {
                                        controller.removeGroupAdmin(
                                            snapshot.data![index].memberId!);
                                      }
                                      Navigator.pop(context);
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
