import 'package:check_in/utils/Constants/constants.dart';

class GroupDetailModel {
  String? groupName;
  String? groupDesc;
  String? groupImg;
  bool? isAdmin;
  GroupDetailModel(
      {this.groupName, this.groupDesc, this.groupImg, this.isAdmin});

  factory GroupDetailModel.fromJson(Map<String, dynamic> json, bool isAdmin) {
    return GroupDetailModel(
        groupName: json[MessageField.GROUP_NAME],
        groupDesc: json[MessageField.ABOUT_GROUP],
        groupImg: json[MessageField.GROUP_IMG],
        isAdmin: isAdmin);
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[MessageField.GROUP_NAME] = groupName;
    data[MessageField.ABOUT_GROUP] = groupDesc;
    data[MessageField.GROUP_IMG] = groupImg;
    data[MessageField.IS_ADMIN] = isAdmin;

    return data;
  }
}
