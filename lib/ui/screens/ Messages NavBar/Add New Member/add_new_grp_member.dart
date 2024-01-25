import 'package:cached_network_image/cached_network_image.dart';
import 'package:check_in/controllers/Messages/add_group_member_controller.dart';
import 'package:check_in/controllers/Messages/chat_controller.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/ui/widgets/custom_appbar.dart';
import 'package:check_in/ui/widgets/text_field.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class AddNewGroupMember extends StatefulWidget {
  String? docId;
  AddNewGroupMember({super.key, this.docId});

  @override
  State<AddNewGroupMember> createState() => _AddNewGroupMemberState();
}

class _AddNewGroupMemberState extends State<AddNewGroupMember> {
  var userController = Get.find<UserController>();
  var controller = Get.find<AddGroupMembersController>();
  var chatcontroller = Get.find<ChatController>();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      controller.fetchMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: poppinsText(TempLanguage.addMember, 15, bold, blackColor),
        actions: [
          Obx(() => controller.mydata.isNotEmpty
              ? TextButton(
                  onPressed: () async {
                    bool res = await controller.addMember(widget.docId!);
                    // clear searchQuery value
                    controller.searchQuery.value = '';
                    if (res) {
                      controller.mydata.clear();
                      Get.back();
                    }
                  },
                  child: poppinsText(TempLanguage.add, 12, medium, blackColor),
                )
              : const SizedBox())
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          verticalGap(10),
          verticalGap(5),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: poppinsText(TempLanguage.to, 15, medium, blackColor),
              ),
            ],
          ),
          Obx(() => Wrap(
                spacing: 8.0,
                runSpacing: 0.0,
                children: controller.mydata.values.map((value) {
                  UserModel model = value;
                  return Chip(
                    label: Text(model.userName!),
                    onDeleted: () {
                      controller.mydata
                          .removeWhere((key, value) => model.uid == key);
                    },
                  );
                }).toList(),
              )),
          verticalGap(5),
          Container(
            decoration: BoxDecoration(
                color: greyColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25)),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: CustomTextfield1(
              controller: controller.searchController,
              hintText: TempLanguage.search,
              onChanged: (value) {
                controller.searchQuery.value = value;
                controller.updateSearchQuery(value);
              },
            ),
          ),
          verticalGap(10),
          Obx(() => controller.searchQuery.value == ''
              ? Center(
                  child: poppinsText(
                      TempLanguage.typeToFindMember, 12, regular, greyColor),
                )
              : Expanded(
                  child: FutureBuilder(
                  future: Future.value(controller.userDataList),
                  builder: (context, snapshot) {
                    return Obx(() => controller.userDataList.isEmpty
                        ? Center(
                            child: poppinsText(TempLanguage.noMemberFound, 12,
                                regular, greyColor),
                          )
                        : ListView.builder(
                            itemCount: controller.userDataList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: controller
                                                  .userDataList[index]
                                                  .photoUrl ==
                                              ''
                                          ? AssetImage(AppImage.user)
                                              as ImageProvider
                                          : CachedNetworkImageProvider(
                                              controller.userDataList[index]
                                                  .photoUrl!),
                                      radius: 25,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 60.w,
                                                  child: poppinsText(
                                                      controller
                                                              .userDataList[
                                                                  index]
                                                              .userName ??
                                                          '',
                                                      15,
                                                      FontWeight.bold,
                                                      blackColor,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                ),
                                              ],
                                            ),
                                            // SizedBox(
                                            //   width: 45.w,
                                            //   child: poppinsText(
                                            //       'USerabout' ?? '',
                                            //       11,
                                            //       FontWeight.normal,
                                            //       blackColor.withOpacity(0.65),
                                            //       overflow:
                                            //           TextOverflow.ellipsis),
                                            // )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Obx(() => Checkbox(
                                          value: controller.mydata.containsKey(
                                              controller
                                                  .userDataList[index].uid),
                                          onChanged: (value) {
                                            controller.mydata.keys.contains(
                                                    controller
                                                        .userDataList[index]
                                                        .uid)
                                                ? controller.mydata.remove(
                                                    controller
                                                        .userDataList[index]
                                                        .uid!)
                                                : controller.mydata[controller
                                                        .userDataList[index]
                                                        .uid!] =
                                                    controller
                                                        .userDataList[index];
                                            controller.searchController.clear();
                                          },
                                          fillColor:
                                              MaterialStateProperty.resolveWith(
                                                  (states) {
                                            if (!states.contains(
                                                MaterialState.pressed)) {
                                              return greenColor;
                                            }
                                            return null;
                                          }),
                                        ))
                                  ],
                                ),
                              );
                            }));
                  },
                )))
        ]),
      ),
    );
  }
}
