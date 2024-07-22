import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/ui/screens/profile_screen.dart';
import 'package:check_in/ui/widgets/custom_appbar.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';

import '../../ Messages NavBar/other_profile/other_profile_view.dart';

class PostAllLikesView extends StatelessWidget {
  PostAllLikesView({super.key, required this.postId, this.isComment = false});
  String postId;
  bool isComment;

  final newsFeedController = Get.put(NewsFeedController(NewsFeedService()));

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
      body: FutureBuilder(
        future: newsFeedController.fetchLikerUsers(postId),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }else if(!snapshot.hasData){
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: Text(isComment ? 'No react on comments' : 'There are no reacts on the post')),
            );
          }else {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: (){
                        if(snapshot.data![index].uid == FirebaseAuth.instance.currentUser!.uid){
                          pushNewScreen(context, screen: ProfileScreen(isNavBar: false,));
                        }else{
                          pushNewScreen(context, screen: OtherProfileView(uid: snapshot.data![index].uid!));
                        }
                      },
                      child:  Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 6),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 60,
                              child: Stack(
                                children: [
                                  snapshot.data![index].photoUrl!.isNotEmpty ? CircleAvatar(
                                    radius: 26,
                                    backgroundImage: NetworkImage(
                                        snapshot.data![index].photoUrl!),
                                  ) : Container(
                                    height: 5.8.h,
                                    width: 5.8.h,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(width: 2, color: appGreenColor),
                                        image: const DecorationImage(
                                            image: AssetImage(AppAssets.LOGO_NEW), fit: BoxFit.fill)),
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
                            poppinsText(
                                snapshot.data![index].userName!, 15, medium, blackColor)
                          ],
                        ),
                      ),
                    );
                  }),
            );
          }
        }
      ),
    );
  }
}
