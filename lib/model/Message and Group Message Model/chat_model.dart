class Chatmodel {
  String? id;
  String? message;
  String? type;
  String? time;
  String? thumbnail;
  String? seenTimeStamp;
  Chatmodel({this.message, this.id, this.time, this.type, this.thumbnail, this.seenTimeStamp});

  factory Chatmodel.fromJson(Map<String, dynamic> json) {
    return Chatmodel(
        id: json['id'],
        message: json['message'],
        time: json['timeStamp'],
        type: json['type'],
        seenTimeStamp: json['seenTimeStamp'],
        thumbnail: json['thumbnail']);
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['message'] = message;
    data['timeStamp'] = time;
    data['type'] = type;
    data['seenTimeStamp'] = seenTimeStamp;
    data['thumbnail'] = thumbnail;

    return data;
  }
}
