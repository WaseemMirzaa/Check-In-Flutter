import 'package:check_in/ui/widgets/custom_appbar.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FullScreenImage extends StatelessWidget {
  const FullScreenImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBlackColor,
      appBar: CustomAppbar(
        backgroundColor: appBlackColor,
        iconColor: appWhiteColor,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.more_vert),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              child: Image.network(
                'https://img.freepik.com/free-vector/set-realistic-hoodies-mannequins-metal-poles-sweatshirt-model-with-long-sleeve_1441-2010.jpg?size=626&ext=jpg',
              ),
            ),
          ),
          Container(
            color: greyColor.withOpacity(0.4),
            height: 180,
            width: double.infinity,
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      poppinsText(
                          'Daniela Fernández Ramos', 14, bold, appWhiteColor),
                      verticalGap(8),
                      poppinsText(
                          'Me encanto la sesión de fotos que me hizo mi amig😍🥺 sssss',
                          10,
                          medium,
                          appWhiteColor,
                          maxlines: 3),
                      verticalGap(6),
                      poppinsText('THU AT 11:50', 10, medium, appWhiteColor)
                    ],
                  ),
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      AppImage.multiplelike,
                      height: 23,
                    ),
                    horizontalGap(5),
                    poppinsText('31K', 12, medium, appWhiteColor),
                    const Spacer(),
                    poppinsText('356 Comments', 12, medium, appWhiteColor)
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
