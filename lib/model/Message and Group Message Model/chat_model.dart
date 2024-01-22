class Chatmodel {
  String? id;
  String? message;
  String? type;
  String? time;
  // String? image;
  String? seenTimeStamp;
  Chatmodel(
      {this.message,
      this.id,
      this.time,
      this.type,
      // this.image,
      this.seenTimeStamp});

  factory Chatmodel.fromJson(Map<String, dynamic> json) {
    return Chatmodel(
        id: json['id'],
        message: json['message'],
        time: json['timeStamp'],
        type: json['type'],
        seenTimeStamp: json['seenTimeStamp']
        // image:json[]
        );
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['message'] = message;
    data['timeStamp'] = time;
    data['type'] = type;
    data['seenTimeStamp'] = seenTimeStamp;

    return data;
  }
}
