import '../core/constant/constant.dart';

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
  List? followers;
  List? following;

  UserModel(
      {this.userName,
      this.email,
      this.uid,
      this.isVerified,
      this.photoUrl,
      this.checkedIn,
      this.checkedInCourtName,
      this.aboutMe,
      this.homeCourt,
      this.goldenCheckin,
      this.followers,
      this.following});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      UserKey.EMAIL: email,
      UserKey.UID: uid,
      UserKey.USER_NAME: userName,
      UserKey.IS_VERIFIED: isVerified,
      UserKey.PHOTO_URL: photoUrl,
      UserKey.CHECKED_IN: checkedIn,
      UserKey.CHECKED_IN_COURT_NAME: checkedInCourtName,
      UserKey.ABOUT_ME: aboutMe,
      UserKey.HOME_COURT: homeCourt,
      UserKey.GOLDEN_CHECK_IN: goldenCheckin,
      UserKey.FOLLOWERS: followers,
      UserKey.FOLLOWING: following,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        userName: map[UserKey.USER_NAME] ?? "",
        email: map[UserKey.EMAIL] ?? "",
        uid: map[UserKey.UID] ?? "",
        isVerified: map[UserKey.IS_VERIFIED] ??
            true, //because all previous users are verified
        photoUrl: map[UserKey.PHOTO_URL] ?? "",
        checkedIn: map[UserKey.CHECKED_IN] ?? false,
        checkedInCourtName: map[UserKey.CHECKED_IN_COURT_NAME] ?? "",
        aboutMe: map[UserKey.ABOUT_ME] ?? "",
        homeCourt: map[UserKey.HOME_COURT] ?? "",
        goldenCheckin: map[UserKey.GOLDEN_CHECK_IN] ?? 0,
        followers: map[UserKey.FOLLOWERS] ?? [],
        following: map[UserKey.FOLLOWING] ?? []);
  }

  UserModel copyWith({
    String? userName,
    String? email,
    String? uid,
    bool? isVerified,
    String? photoUrl,
    bool? checkedIn,
    String? checkedInCourtName,
    // String? checkedCourts,
    String? aboutMe,
    String? homeCourt,
    int? goldenCheckin,
    List? followers,
    List? following,
  }) {
    return UserModel(
      userName: userName ?? this.userName,
      email: email ?? this.email,
      uid: uid ?? this.uid,
      isVerified: isVerified ?? this.isVerified,
      photoUrl: photoUrl ?? this.photoUrl,
      checkedIn: checkedIn ?? this.checkedIn,
      checkedInCourtName: checkedInCourtName ?? this.checkedInCourtName,
      aboutMe: aboutMe ?? this.aboutMe,
      homeCourt: homeCourt ?? this.homeCourt,
      goldenCheckin: goldenCheckin ?? this.goldenCheckin,
      followers: followers ?? this.followers,
      following: following ?? this.following,
    );
  }
}
