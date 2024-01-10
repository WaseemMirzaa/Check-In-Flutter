import 'package:check_in/model/Message%20and%20Group%20Message%20Model/group_member_model.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class GroupMemberTile extends StatelessWidget {
  GroupMemberModel? data;
  Function(dynamic)? ontap;
  GroupMemberTile({super.key, this.data, this.ontap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          height: 78,
          width: 50,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: greenColor.withOpacity(0.6),
                backgroundImage: NetworkImage(data!.memberImg!),
                radius: 30,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 43.w,
                            child: poppinsText(data!.memberName!, 15,
                                FontWeight.bold, blackColor,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 45.w,
                        child: poppinsText(
                          'aboutt',
                          12,
                          FontWeight.normal,
                          blackColor.withOpacity(0.65),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              data!.isAdmin!
                  ? Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                          color: greyColor.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        'Admin',
                        style: TextStyle(color: greenColor),
                      ),
                    )
                  : PopupMenuButton(
                      itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(
                              value: 'makegroupadmin',
                              child: Text('Make Group Admin'),
                            ),
                          ],
                      elevation: 10,
                      position: PopupMenuPosition.under,
                      onSelected: ontap)
            ],
          ),
        ),
      ),
    );
  }
}
