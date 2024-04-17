import 'package:cloud_firestore/cloud_firestore.dart';

class Chatmodel {
  String? id;
  String? docID;
  bool? isDelete;
  bool? isRead;
  String? message;
  String? type;
  //String? time;
  Timestamp? time;
  String? thumbnail;
  //String? seenTimeStamp;
  Timestamp? seenTimeStamp;
  Chatmodel({this.message, this.id, this.docID,this.isDelete,this.isRead, this.time, this.type, this.thumbnail, this.seenTimeStamp});

  factory Chatmodel.fromJson(Map<String, dynamic> json, {String? docID}) {
    return Chatmodel(
        id: json['id'],
        docID: docID,
        isDelete: json['isDelete'],
        isRead: json['isRead'],
        message: json['message'],
        time: json['timeStamp'],
        type: json['type'],
        seenTimeStamp: json['seenTimeStamp'],
        thumbnail: json['thumbnail']);
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['isDelete'] = isDelete;
    data['isRead'] = isRead;
    data['message'] = message;
    data['timeStamp'] = time;
    data['type'] = type;
    data['seenTimeStamp'] = seenTimeStamp;
    data['thumbnail'] = thumbnail;

    return data;
  }
}
