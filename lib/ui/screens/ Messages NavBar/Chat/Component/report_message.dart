import 'package:check_in/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../../../controllers/Messages/chat_controller.dart';

class ReportMessage extends StatelessWidget {
  const ReportMessage({
    super.key,
    required this.docId,
    required this.messageId,
    required this.reportedBy
  });

  final String messageId;
  final String reportedBy;
  final String docId;

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<ChatController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Message'),
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
                    final res = await controller.reportMessage(docId, messageId, reportedBy, snapshot.data![index]);
                    Get.back();
                    if (res) {
                      toast('Message reported successfully');
                    } else {
                      toast('Error occurred');
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
