class UserModel {
  String? userName;
  String? email;
  String? uid;

  UserModel({this.userName, this.email, this.uid});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'uid': uid,
      "user name": userName,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userName: map['user name'] != null ? map['fullName'] as String : "",
      email: map['email'] != null ? map['email'] as String : "",
      uid: map['uid'] != null ? map['uid'] as String : "",
    );
  }
}
