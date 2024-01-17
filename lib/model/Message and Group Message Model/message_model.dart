import 'package:check_in/core/constant/constant.dart';

class Messagemodel {
  String? id;
  String? name;
  String? image;
  String? lastmessage;
  num? unreadmsg;
  bool? isgroup;
  String? timeStamp;
  String? senderId;
  String? requestStatus;
  String? senderName;
  String? recieverName;
  bool? showMessageTile;
  Messagemodel({
    this.name,
    this.lastmessage,
    this.id,
    this.unreadmsg,
    this.isgroup,
    this.image,
    this.timeStamp,
    this.senderId,
    this.requestStatus,
    this.senderName,
    this.recieverName,
    this.showMessageTile,
  });

  factory Messagemodel.fromJson(Map<String, dynamic> json,
      {name, image, unread, showMessageTile}) {
    return Messagemodel(
      id: json[MessageField.ID],
      name: name ?? '',
      image: image ?? '',
      lastmessage: json[MessageField.LAST_MESSAGE],
      unreadmsg: unread ?? 0,
      isgroup: json[MessageField.IS_GROUP],
      timeStamp: json[MessageField.TIME_STAMP],
      senderId: json[MessageField.SENDER_ID],
      requestStatus: json[MessageField.REQUEST_STATUS],
      senderName: json[MessageField.SENDER_NAME],
      recieverName: json[MessageField.RECIEVER_NAME],
      showMessageTile: showMessageTile,
    );
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
}
