class UserModel {
  String? userName;
  String? email;
  String? uid;
  bool? isVerified;
  String? photoUrl;
  bool? checkedIn;
  String? checkedInCourtName;
  // String? checkedCourts;
  String? aboutMe;
  String? homeCourt;

  UserModel({this.userName, this.email, this.uid,this.isVerified,this.photoUrl,this.checkedIn,this.checkedInCourtName,this.aboutMe, this.homeCourt});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'uid': uid,
      "user name": userName,
      "isVerified":isVerified,
      "photoUrl":photoUrl,
      "checkedIn":checkedIn,
      "checkedInCourtName":checkedInCourtName,
      "about me":aboutMe,
      "home court":homeCourt,

    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userName: map['user name'] ?? "",
      email: map['email'] ?? "",
      uid: map['uid'] ?? "",
      isVerified: map['isVerified'] ?? true, //because all previous users are verified
      photoUrl: map['photoUrl'] ?? "",
      checkedIn: map['checkedIn'] ?? false,
      checkedInCourtName: map['checkedInCourtName'] ?? "",
      aboutMe: map['about me'] ?? "",
      homeCourt: map['home court'] ?? "",

    );
  }
}
