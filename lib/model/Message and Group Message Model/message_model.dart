import 'package:check_in/core/constant/constant.dart';

class Messagemodel {
  String? id;
  String? name;
  String? image;
  String? lastmessage;
  num? unreadmsg;
  bool? isgroup;
  String? timeStamp;
  Messagemodel(
      {this.name,
      this.lastmessage,
      this.id,
      this.unreadmsg,
      this.isgroup,
      this.image,
      this.timeStamp});

  factory Messagemodel.fromJson(
      Map<String, dynamic> json, name, image, unread) {
    return Messagemodel(
        id: json[MessageField.ID],
        name: name,
        image: image,
        lastmessage: json[MessageField.LAST_MESSAGE],
        unreadmsg: unread,
        isgroup: json[MessageField.IS_GROUP],
        timeStamp: json[MessageField.TIME_STAMP]);
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
