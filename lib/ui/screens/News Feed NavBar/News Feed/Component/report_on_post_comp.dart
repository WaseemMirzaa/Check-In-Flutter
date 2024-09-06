import 'package:check_in/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

class Report extends StatelessWidget {
  const Report({
    super.key,
    this.postId = '',
    required this.reportedBy,
    required this.isProfile,
    this.profileId = ''
  });

  final String postId;
  final String reportedBy;
  final bool isProfile;
  final String profileId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Content'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<String>>(
        future: newsFeedController.getReportArray(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error in fetching data'));
          } else if (snapshot.hasData && snapshot.data != null) {

            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () async {
                    if (isProfile) {
                      final res = await newsFeedController.reportProfile(profileId, reportedBy, snapshot.data![index]);
                      Get.back(result: res);
                      if (res) {
                        toast('Profile reported successfully');
                      } else {
                        toast('Error occurred');
                      }
                    } else {
                      final res = await newsFeedController.reportPost(postId, reportedBy, snapshot.data![index]);
                      Get.back(result: res);
                      if (res) {
                        toast('Post reported successfully');
                      } else {
                        toast('Error occurred');
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          snapshot.data![index]
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('Something went wrong'));
          }
        },
      ),
    );
  }
}
