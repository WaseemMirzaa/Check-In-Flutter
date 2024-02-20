class Chatmodel {
  String? id;
  String? docID;
  bool? isDelete;
  String? message;
  String? type;
  String? time;
  String? thumbnail;
  String? seenTimeStamp;
  Chatmodel({this.message, this.id, this.docID,this.isDelete, this.time, this.type, this.thumbnail, this.seenTimeStamp});

  factory Chatmodel.fromJson(Map<String, dynamic> json, {String? docID}) {
    return Chatmodel(
        id: json['id'],
        docID: docID,
        isDelete: json['isDelete'],
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
    data['message'] = message;
    data['timeStamp'] = time;
    data['type'] = type;
    data['seenTimeStamp'] = seenTimeStamp;
    data['thumbnail'] = thumbnail;

    return data;
  }
}
