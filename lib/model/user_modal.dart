class UserModel {
  String? userName;
  String? email;
  String? uid;
  bool? isVerified;

  UserModel({this.userName, this.email, this.uid,this.isVerified});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'uid': uid,
      "user name": userName,
      "isVerified":isVerified
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userName: map['user name'] != null ? map['fullName'] as String : "",
      email: map['email'] != null ? map['email'] as String : "",
      uid: map['uid'] != null ? map['uid'] as String : "",
      isVerified: map['isVerified'] != null ? map["isVerified"] as bool : false,
    );
  }
}
