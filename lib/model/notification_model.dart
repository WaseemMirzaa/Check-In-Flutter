// class NotificationModel {
//   static String type = "";
//   static String body = "";
//   static String docId = "";
//   static String name = "";
//   static String image = "";
//   static List memberIds = [];
//   static bool isGroup = false;
// }

class NotificationModel {
  static final NotificationModel _instance = NotificationModel._internal();
  factory NotificationModel() => _instance;
  NotificationModel._internal();

  String type = "";
  String body = "";
  String docId = "";
  String name = "";
  String image = "";
  List memberIds = [];
  bool isGroup = false;

}
