import 'dart:io';

import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/auth_service.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/NewsFeed%20Model/news_feed_model.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/Create%20Post/create_post_screen.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/list_tile_container.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/shared_post_comp.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/top_container.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/test_aid_comp/test_aid_comp.dart';
import 'package:check_in/ui/widgets/custom_container.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/loader.dart';
import 'package:check_in/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';
import '../../../widgets/custom_appbar.dart';

class MyPostsNewsFeed extends StatefulWidget {
  MyPostsNewsFeed({super.key, this.postId = ''});
  String postId;

  @override
  State<MyPostsNewsFeed> createState() => _MyPostsNewsFeedState();
}

class _MyPostsNewsFeedState extends State<MyPostsNewsFeed> {
  final controller = Get.put(NewsFeedController(NewsFeedService()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppbar(
          showicon: true,
          title: poppinsText(
              TempLanguage.myPosts, 15, FontWeight.bold, appBlackColor),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0,vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(radius: 40.sp,backgroundImage: NetworkImage(_downloadUrl ?? userController.userModel.value.photoUrl!),),
                    GestureDetector(
                        onTap: _selectImage,
                        child: CircleAvatar(radius: 18.sp,backgroundColor: appGreenColor,child: Padding(padding: const EdgeInsets.all(4),child: Icon(Icons.camera_alt,color: appWhiteColor,),),))
                  ],
                ),
                  horizontalGap(20),
                  poppinsText(userController.userModel.value.userName!, 14.sp, bold, appBlackColor)
              ],),
            ),


              StreamBuilder<List<NewsFeedModel>>(
                  stream: controller.getMyPosts(FirebaseAuth.instance.currentUser?.uid ?? ''),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return loaderView();
                    } else if (!snapshot.hasData) {
                      return Center(child: Text(TempLanguage.noPostFound));
                    }else if (snapshot.data!.isEmpty) {
                      return Center(child: Text(TempLanguage.noPostFound));
                    } else if(snapshot.hasError){
                      return Center(child: Text(snapshot.error.toString()),);
                    } else {
                      return ListView.builder(
                          key: const ValueKey('listViewBuilder'),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount:  snapshot.data!.length,
                          itemBuilder: (context, index) {

                            var data = snapshot.data![index];
                            return data.isOriginal! ? ListTileContainer(
                              key: ValueKey(data.id),
                              data: data,
                            ) : SharedPostComp(
                                key: ValueKey(data.id),
                                data:data);
                          });
                    }
                  })
            ],
          ),
        ));
  }
  File? _imageFile;
  String? _downloadUrl;

  Future<void> _selectImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      final storage = FirebaseStorage.instance;
      final ref = storage.ref()
      // .child('profile/${DateTime.now().millisecondsSinceEpoch}');
          .child('profile/${FirebaseAuth.instance.currentUser?.uid ?? ""}');
      final uploadTask = ref.putFile(_imageFile!);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _downloadUrl = downloadUrl;
      });

      final firestore = FirebaseFirestore.instance;
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await firestore.collection(Collections.USER).doc(userId).update({UserKey.PHOTO_URL: downloadUrl});
      CollectionReference messagesRef = FirebaseFirestore.instance.collection(Collections.MESSAGES);

      QuerySnapshot messagesQuery = await messagesRef.where(MessageField.SENDER_ID, isEqualTo: userController.userModel.value.uid).get();

      // Iterate through the documents and update senderImage field
      messagesQuery.docs.forEach((doc) async {
        // Update the senderImage field with the new image URL
        await messagesRef.doc(doc.id).update({
          MessageField.SENDER_IMG: downloadUrl,
        });
      });
      await firestore.collection(Collections.MESSAGES).where(MessageField.SENDER_ID, isEqualTo: userController.userModel.value.uid);
    }
  }

}
