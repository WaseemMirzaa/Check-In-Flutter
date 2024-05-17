class Collections {
  static const USER = 'USER';
  static const GOLDEN_LOCATIONS = 'goldenLocations';
  static const String MESSAGES = 'messages';
  static const String CHAT = 'chat';
  static const String NEWSFEED = 'newsFeed';

  ///
}

class UserKey {
  static const EMAIL = 'email';
  static const UID = 'uid';
  static const CUSTOMER_ID = 'customerId';
  static const USER_NAME = 'user name';
  static const IS_VERIFIED = 'isVerified';
  static const PHOTO_URL = 'photoUrl';
  static const CHECKED_IN = 'checkedIn';
  static const CHECKED_IN_COURT_NAME = "checkedInCourtName";
  static const ABOUT_ME = "about me";
  static const HOME_COURT = "home court";
  static const GOLDEN_CHECK_IN = "goldenCheckin";
  static const DEVICE_TOKEN = "deviceToken";
  static const PARAMS = "params";
}

class CourtKey {
  static const COURT_NAME = 'courtName';
  static const COURT_LAT = 'courtLat';
  static const COURT_LNG = 'courtLng';
  static const IS_GOLDEN = 'isGolden';
  static const LAT = 'lat';
  static const LNG = 'lng';
  static const CHECKED_COURTS = 'checkedCourts';
  static const GOLDEN = 'golden';
  static const NAME = 'name';
  static const ID = 'id';
}

class MessageField {
  static const String GROUP_IMG = 'groupImg';
  static const String GROUP_NAME = 'groupName';
  static const String ID = 'id';
  static const String IS_GROUP = 'isGroup';
  static const String LAST_MESSAGE = 'lastMessage';
  static const String MEMBER_IDS = 'memberIds';
  static const String MEMBERS = 'members';
  static const String TIME_STAMP = 'timeStamp';
  static const String MEMBER_NAME = 'name';
  static const String MEMBER_UID = 'uid';
  static const String MEMBER_UNREAD_COUNT = 'unreadCount';
  static const String MEMBER_IMG = 'image';
  static const String RECIEVER_ID = 'recieverId';
  static const String RECIEVER_IMG = 'recieverImg';
  static const String RECIEVER_NAME = 'recieverName';
  static const String RECIEVER_UNREAD = 'recieverUnread';
  static const String SENDER_ID = 'senderId';
  static const String SENDER_IMG = 'senderImg';
  static const String SENDER_NAME = 'senderName';
  static const String SENDER_UNREAD = 'senderUnread';
  static const String ABOUT_GROUP = 'aboutGroup';
  static const String RECIEVER_ABOUT = 'recieverAbout';
  static const String SENDER_ABOUT = 'senderAbout';
  static const String IS_ADMIN = 'isAdmin';
  static const String IS_OWNER = 'isOwner';
  static const String ABOUT_USER = 'about';
  static const String REQUEST_STATUS = 'requestStatus';
  static const String DELETE_IDS = 'deleteIds';
  static const String DELETE_TIMESTAMP = 'deleteTimeStamp';
  static const String IS_DELETED = 'isDeleted';
}

class ChatField {
  static const String ID = 'id';
  static const String MESSAGE = 'message';
  static const String TIME_STAMP = 'timeStamp';
}

class NewsFeed {
  static const String DESCRIPTION = 'description';
  static const String NAME = 'userName';
  static const String USER_ID = 'userId';
  static const String FEED_ID = 'feedId';
  static const String USER_IMAGE = 'userImage';
  static const String POST_URL = 'postUrl';
  static const String IS_TYPE = 'isType';
  static const String NO_OF_LIKE = 'noOfLike';
  static const String NO_OF_COMMENT = 'noOfComment';
  static const String NO_OF_SHARED = 'noOfShared';
}

class SharedPreferenceKey {
  static const NOTIFICATION_BADGE = "NOTIFICATION_BADGE";
}
