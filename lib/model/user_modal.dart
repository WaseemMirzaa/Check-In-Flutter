class UserModel {
  String? userName;
  String? email;
  String? uid;
  bool? IsVerified;

  UserModel({this.userName, this.email, this.uid,this.IsVerified});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'uid': uid,
      "user name": userName,
      "IsVerified":IsVerified
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userName: map['user name'] != null ? map['fullName'] as String : "",
      email: map['email'] != null ? map['email'] as String : "",
      uid: map['uid'] != null ? map['uid'] as String : "",
      IsVerified: map['IsVerified'] != null ? map["IsVerified"] as bool : false,
    );
  }
}
