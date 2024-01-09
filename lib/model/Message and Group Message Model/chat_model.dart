class Chatmodel {
  String? id;
  String? message;
  String? time;
  Chatmodel({this.message, this.id, this.time});

  factory Chatmodel.fromJson(Map<String, dynamic> json) {
    return Chatmodel(
      id: json['id'],
      message: json['message'],
      time: json['timeStamp'],
    );
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['message'] = message;
    data['timeStamp'] = time;

    return data;
  }
}
