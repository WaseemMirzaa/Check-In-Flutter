import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/utils/common.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Messagemodel {
  String? id;
  String? name;
  String? yourname;
  String? image;
  String? lastmessage;
  num? unreadmsg;
  bool? isgroup;

  //String? timeStamp;
  Timestamp? timeStamp;
  String? requestStatus;
  String? senderId;
  String? senderImg;
  String? senderName;
  String? recieverName;
  String? recieverId;
  String? recieverImg;
  List? memberIds;
  List? deleteIds;
  List? members;
  bool? showMessageTile;
  String? blockId;

  Messagemodel({
    this.name,
    this.yourname,
    this.lastmessage,
    this.id,
    this.unreadmsg,
    this.isgroup,
    this.image,
    this.timeStamp,
    this.senderId,
    this.recieverId,
    this.requestStatus,
    this.senderName,
    this.recieverName,
    this.memberIds,
    this.deleteIds,
    this.showMessageTile,
    this.members,
    this.senderImg,
    this.recieverImg,
    this.blockId
  });

  factory Messagemodel.fromJson(Map<String, dynamic> json,
      {name, image, unread, showMessageTile, yourName, deleteIds}) {
    return Messagemodel(
        id: json[MessageField.ID],
        name: name ?? '',
        image: image ?? '',
        lastmessage: json[MessageField.LAST_MESSAGE],
        unreadmsg: unread ?? 0,
        isgroup: json[MessageField.IS_GROUP],
        timeStamp: json[MessageField.TIME_STAMP] is !Timestamp ? convertDateToTimeStamp(json[MessageField.TIME_STAMP]) : json[MessageField.TIME_STAMP],
        senderId: json[MessageField.SENDER_ID],
        requestStatus: json[MessageField.REQUEST_STATUS],
        senderName: json[MessageField.SENDER_NAME],
        recieverName: json[MessageField.RECIEVER_NAME],
        recieverId: json[MessageField.RECIEVER_ID],
        memberIds: json[MessageField.MEMBER_IDS],
        deleteIds: deleteIds,
        members: json[MessageField.MEMBERS],
        showMessageTile: showMessageTile,
        recieverImg: json[MessageField.RECIEVER_IMG],
        senderImg: json[MessageField.SENDER_IMG],
        blockId: json[MessageField.BLOCK_ID],
        yourname: yourName);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[MessageField.ID] = id;
    data[''] = name;
    data[MessageField.LAST_MESSAGE] = lastmessage;
    data[''] = unreadmsg;
    data[MessageField.IS_GROUP] = isgroup;
    data[MessageField.TIME_STAMP] = timeStamp;

    return data;
  }

  Messagemodel copyWith(
      {String? id,
      String? name,
      String? yourname,
      String? image,
      String? lastmessage,
      num? unreadmsg,
      bool? isgroup,
      Timestamp? timeStamp,
      String? senderId,
      String? requestStatus,
      String? senderName,
      String? recieverName,
      String? recieverId,
      String? blockerId,
      List? memberIds,
      List? deleteIds,
      List? members,
      bool? showMessageTile}) {
    return Messagemodel(
      id: id ?? this.id,
      name: name ?? this.name,
      yourname: yourname ?? this.yourname,
      image: image ?? this.image,
      lastmessage: lastmessage ?? this.lastmessage,
      unreadmsg: unreadmsg ?? this.unreadmsg,
      isgroup: isgroup ?? this.isgroup,
      timeStamp: timeStamp ?? this.timeStamp,
      senderId: senderId ?? this.senderId,
      requestStatus: requestStatus ?? this.requestStatus,
      senderName: senderName ?? this.senderName,
      recieverName: recieverName ?? this.recieverName,
      recieverId: recieverId ?? this.recieverId,
      memberIds: memberIds ?? this.memberIds,
      deleteIds: deleteIds ?? this.deleteIds,
      members: members ?? this.members,
      showMessageTile: showMessageTile ?? this.showMessageTile,
        blockId: blockerId ?? this.blockId
    );
  }
}
