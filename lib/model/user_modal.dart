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
  int? goldenCheckin;

  UserModel({this.userName, this.email, this.uid,this.isVerified,this.photoUrl,this.checkedIn,this.checkedInCourtName,this.aboutMe, this.homeCourt, this.goldenCheckin});

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
      "goldenCheckin":goldenCheckin,

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
      goldenCheckin: map['goldenCheckin'] ?? 0,

    );
  }
}
