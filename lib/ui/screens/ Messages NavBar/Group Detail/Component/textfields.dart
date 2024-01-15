import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../../controllers/Messages/group_detail_controller.dart';
import '../../../../../utils/colors.dart';

class NameTextfield extends GetView<GroupDetailController> {
  bool? readOnly;
  bool? isAdmin;
  Function()? iconOnTap;

  NameTextfield({super.key, this.isAdmin, this.readOnly, this.iconOnTap});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: isAdmin == true && readOnly == true ? false : true,
      focusNode: controller.namefocusNode,
      onTapOutside: (val) {
        controller.namefocusNode.unfocus();
      },
      controller: controller.nameController,
      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: greyColor.withOpacity(0.6))),
          suffixIcon: isAdmin!
              ? GestureDetector(
                  onTap: iconOnTap,
                  child: Padding(
                      padding:
                          const EdgeInsets.only(top: 20, bottom: 10, left: 30),
                      child: Obx(
                        () => controller.nameTapped.value
                            ? poppinsText(
                                TempLanguage.save, 14, semiBold, greenColor)
                            : SizedBox(
                                height: 2.h,
                                child: Image.asset(
                                  AppAssets.EDIT_ICON,
                                ),
                              ),
                      )))
              // Padding(
              //     padding: const EdgeInsets.only(top: 20, bottom: 10, left: 30),
              //     child: Obx(
              //       () => controller.tapped.value
              //           ? poppinsText(
              //               TempLanguage.save, 14, semiBold, greenColor)
              //           : SvgPicture.asset(
              //               AppImage.penicon,
              //             ),
              //     ))
              : const SizedBox()),
    );
  }
}

class AboutTextfield extends GetView<GroupDetailController> {
  bool? readOnly;
  bool? isAdmin;
  AboutTextfield({super.key, this.isAdmin, this.readOnly});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: isAdmin == true && readOnly == true ? false : true,
      onTapOutside: (val) {
        controller.aboutfocusNode.unfocus();
      },
      focusNode: controller.aboutfocusNode,
      enabled: true,
      // textAlign: TextAlign.center,
      maxLines: 3,
      // minLines: 1,
      controller: controller.aboutController,
      style: TextStyle(fontSize: 14, color: greyColor),
      decoration: const InputDecoration(
        border: UnderlineInputBorder(borderSide: BorderSide.none),
      ),
    );
  }
}
