import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  String? reportId;
  String? postId;
  String? profileId;
  String? reportedBy;
  String? reason;
  String? docId;
  String? messageId;
  Timestamp? timestamp;

  ReportModel({
    this.reportId,
    this.postId,
    this.reportedBy,
    this.reason,
    this.timestamp,
    this.profileId,
    this.docId,
    this.messageId
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      reportId: json['reportId'],
      postId: json['postId'],
      reportedBy: json['reportedBy'],
      reason: json['reason'],
      profileId: json['profileId'],
      timestamp: json['timestamp'],
      docId: json['docId'],
      messageId: json['messageId']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'postId': postId,
      'reportedBy': reportedBy,
      'reason': reason,
      'timestamp': timestamp,
      'profileId': profileId,
      'messageId': messageId,
      'docId': docId
    };
  }
}
