import 'package:check_in/ui/widgets/custom_appbar.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';

class AllLikesScreen extends StatelessWidget {
  const AllLikesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: Row(
          children: [
            SvgPicture.asset(
              AppImage.like1,
              height: 20,
            ),
            const Spacer(),
            poppinsText('Likes', 15, bold, blackColor),
            const Spacer(
              flex: 3,
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ListView.builder(
                  itemCount: 12,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 60,
                            child: Stack(
                              children: [
                                const CircleAvatar(
                                  radius: 26,
                                  backgroundImage: NetworkImage(
                                      'https://wac-cdn.atlassian.com/dam/jcr:ba03a215-2f45-40f5-8540-b2015223c918/Max-R_Headshot%20(1).jpg?cdnVersion=1365'),
                                ),
                                Positioned(
                                  bottom: 1,
                                  right: 1,
                                  child: CircleAvatar(
                                    backgroundColor: whiteColor,
                                    radius: 14,
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: greenColor,
                                      child: SvgPicture.asset(
                                        AppImage.like,
                                        color: white,
                                        height: 10,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          horizontalGap(12),
                          poppinsText('Julian Dasilva', 15, medium, blackColor)
                        ],
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
