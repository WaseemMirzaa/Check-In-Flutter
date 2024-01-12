import 'package:cached_network_image/cached_network_image.dart';
import 'package:check_in/controllers/Messages/new_message_controller.dart';
import 'package:check_in/ui/widgets/custom_appbar.dart';
import 'package:check_in/ui/widgets/text_field.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class NewMessageScreen extends GetView<NewMessageController> {
  const NewMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: poppinsText('New Messages', 15, bold, blackColor),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            verticalGap(10),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: poppinsText('To', 15, medium, blackColor),
            ),
            verticalGap(5),
            Container(
              decoration: BoxDecoration(
                  color: greyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25)),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CustomTextfield1(
                hintText: 'Search',
                onTap: () {},
              ),
            ),
            verticalGap(10),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: poppinsText('Suggested', 15, medium, blackColor),
            ),
            verticalGap(5),
            Expanded(
              child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, snapshot) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                                AppImage.userImagePath),
                            radius: 25,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 43.w,
                                        child: poppinsText('UserNAme' ?? '', 15,
                                            FontWeight.bold, blackColor,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 45.w,
                                    child: poppinsText(
                                        'USerabout' ?? '',
                                        11,
                                        FontWeight.normal,
                                        blackColor.withOpacity(0.65),
                                        overflow: TextOverflow.ellipsis),
                                  )
                                ],
                              ),
                            ),
                          ),
                     Radio(value: 'uservalue', groupValue: '', onChanged: (value){})
                        ],
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
