// ignore_for_file: must_be_immutable

import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/utils/colors.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/foundation.dart' as foundation;

class StickerKeyboard extends StatelessWidget {
  TextEditingController? controller;
  StickerKeyboard({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 25.h,
        child: EmojiPicker(
          onBackspacePressed: () {},
          textEditingController: controller,
          config: Config(
              columns: 7,
              emojiSizeMax: 25 *
                  (foundation.defaultTargetPlatform == TargetPlatform.iOS
                      ? 1.30
                      : 1.0),
              recentsLimit: 30,
              noRecents: Text(
                TempLanguage.noRecent,
                style: const TextStyle(fontSize: 20, color: Colors.black26),
                textAlign: TextAlign.center,
              ),
              loadingIndicator: const SizedBox.shrink(),
              tabIndicatorAnimDuration: kTabScrollDuration,
              categoryIcons: const CategoryIcons(),
              checkPlatformCompatibility: true,
              iconColorSelected: greenColor,
              backspaceColor: greenColor),
        ));
  }
}
