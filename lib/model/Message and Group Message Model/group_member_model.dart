import 'package:check_in/core/constant/constant.dart';

class GroupMemberModel {
  String? memberId;
  String? memberName;
  String? memberDesc;
  String? memberImg;
  bool? isAdmin;
  bool? isOwner;
  bool? iAmAdmin;
  GroupMemberModel(
      {this.memberName,
      this.memberDesc,
      this.memberImg,
      this.isAdmin,
        this.isOwner,
      this.iAmAdmin,
      this.memberId});

  factory GroupMemberModel.fromJson(Map<String, dynamic> json, bool iAmAdmin) {
    return GroupMemberModel(
        memberName: json[MessageField.MEMBER_NAME],
        memberDesc: json[MessageField.ABOUT_USER],
        memberImg: json[MessageField.MEMBER_IMG],
        isAdmin: json[MessageField.IS_ADMIN],
        memberId: json[MessageField.MEMBER_UID],
        isOwner: json[MessageField.IS_OWNER],
        iAmAdmin: iAmAdmin);
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[MessageField.GROUP_NAME] = memberName;
    data[MessageField.ABOUT_GROUP] = memberDesc;
    data[MessageField.MEMBER_IMG] = memberImg;
    data[MessageField.IS_ADMIN] = isAdmin;
    data[MessageField.MEMBER_UID] = memberId;

    return data;
  }
}
