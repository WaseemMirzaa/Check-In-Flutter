class Chatmodel {
  String? id;
  String? message;
  String? type;
  String? time;
  Chatmodel({this.message, this.id, this.time, this.type});

  factory Chatmodel.fromJson(Map<String, dynamic> json) {
    return Chatmodel(
        id: json['id'],
        message: json['message'],
        time: json['timeStamp'],
        type: json['type']);
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['message'] = message;
    data['timeStamp'] = time;
    data['type'] = type;

    return data;
  }
}
