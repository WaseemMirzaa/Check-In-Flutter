class Messagemodel {
  String? id;
  String? name;
  String? image;
  String? lastmessage;
  String? unreadmsg;
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

  factory Messagemodel.fromJson(Map<String, dynamic> json, name, image) {
    return Messagemodel(
        id: json['id'],
        name: name,
        image: image,
        lastmessage: json['lastMessage'],
        unreadmsg: json['unreadMsg'],
        isgroup: json['isGroup'],
        timeStamp: json['timeStamp']);
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['recieverName'] = name;
    data['lastMessage'] = lastmessage;
    data['unreadMsg'] = unreadmsg;
    data['isGroup'] = isgroup;
    data['timeStamp'] = timeStamp;

    return data;
  }
}
