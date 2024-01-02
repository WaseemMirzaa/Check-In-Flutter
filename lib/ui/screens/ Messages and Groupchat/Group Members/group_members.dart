import 'package:check_in/controllers/group_members_controller.dart';
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
          StreamBuilder<List<dynamic>>(
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
                child: StreamBuilder<List<dynamic>>(
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
                              if (snapshot.data![index]['name']!
                                  .toLowerCase()
                                  .contains(
                                      controller.searchQuery.toLowerCase())) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  child: Material(
                                    elevation: 5,
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      height: 78,
                                      width: 50,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Row(
                                        children: [
                                          const CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                'https://wac-cdn.atlassian.com/dam/jcr:ba03a215-2f45-40f5-8540-b2015223c918/Max-R_Headshot%20(1).jpg?cdnVersion=1365'),
                                            radius: 30,
                                          ),
                                          Padding(
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
                                                      width: 45.w,
                                                      child: poppinsText(
                                                          snapshot.data![index]
                                                              ['name'],
                                                          15,
                                                          FontWeight.bold,
                                                          blackColor,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 50.w,
                                                  child: poppinsText(
                                                    'aboutt',
                                                    12,
                                                    FontWeight.normal,
                                                    blackColor
                                                        .withOpacity(0.65),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
