// ignore_for_file: unused_local_variable, avoid_print

import 'dart:developer';
import 'dart:io';

import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/chat_model.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/group_detail_model.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/group_member_model.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/utils/Constants/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../model/Message and Group Message Model/message_model.dart';

List<dynamic> mem = [];

class MessageService {
  int unreadCount = 0;
  final db = FirebaseFirestore.instance;
  final CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection(Collections.MESSAGES);
  final FirebaseStorage _storage = FirebaseStorage.instance;

//............ Get Message
  Stream<List<Messagemodel>> getChatMessage(String myId) {
    return _messagesCollection
        .where(MessageField.MEMBER_IDS, arrayContains: myId)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.map<Messagemodel>((doc) {
              num unread = 0;
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              bool showMessagetile = false;
              String name, imagepath, yourname = '';

              if (data[MessageField.IS_GROUP] == true) {
                name = data[MessageField.GROUP_NAME];
                imagepath = data[MessageField.GROUP_IMG];
                mem = data[MessageField.MEMBERS];
                yourname = data[MessageField.GROUP_NAME];

                for (var val in mem) {
                  if (val[MessageField.MEMBER_UID] == myId) {
                    unread = val[MessageField.MEMBER_UNREAD_COUNT];
                    showMessagetile = true;
                    break;
                  }
                }
              } else {
                name = data[MessageField.SENDER_ID] == myId
                    ? data[MessageField.RECIEVER_NAME]
                    : data[MessageField.SENDER_NAME];
                yourname = data[MessageField.SENDER_ID] == myId
                    ? data[MessageField.SENDER_NAME]
                    : data[MessageField.RECIEVER_NAME];
                imagepath = data[MessageField.SENDER_ID] == myId
                    ? data[MessageField.RECIEVER_IMG]
                    : data[MessageField.SENDER_IMG];
                unread = data[MessageField.SENDER_ID] == myId
                    ? data[MessageField.SENDER_UNREAD]
                    : data[MessageField.RECIEVER_UNREAD];
                showMessagetile = data[MessageField.RECIEVER_ID] == myId &&
                        data[MessageField.REQUEST_STATUS] ==
                            RequestStatusEnum.delete.name
                    ? false
                    : true;
              }
              return Messagemodel.fromJson(doc.data() as Map<String, dynamic>,
                  name: name,
                  image: imagepath,
                  unread: unread,
                  showMessageTile: showMessagetile,
                  yourName: yourname);
            }).toList());
  }

//............ Get conversations
  Stream<List<Chatmodel>> getConversation(String docId, String uId) {
    return _messagesCollection
        .doc(docId)
        .collection(Collections.CHAT)
        .orderBy(ChatField.TIME_STAMP, descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.map<Chatmodel>((doc) {
              // updateLastSeen(docId, uId);
              updateUnreadCount(docId, uId, 0);
              return Chatmodel.fromJson(doc.data());
            }).toList());
  }

//............ Update last Seen
  Future<void> updateLastSeen(String docId, String uid) async {
    print(uid);
    final docRef = _messagesCollection.doc(docId);
    final CollectionReference subcollectionRef =
        docRef.collection(Collections.CHAT);

    // QuerySnapshot subcollectionSnapshot = await subcollectionRef.get();
    QuerySnapshot subcollectionSnapshot =
        await subcollectionRef.where('id', isNotEqualTo: uid).get();

    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (QueryDocumentSnapshot docSnapshot in subcollectionSnapshot.docs) {
      batch.update(
        subcollectionRef.doc(docSnapshot.id),
        {'seenTimeStamp': DateTime.now().toString()},
      );
    }
    await batch.commit();
  }

//............ Update Unread Count
  Future<void> updateUnreadCount(
    String docId,
    String uId,
    num unreadval,
  ) async {
    final docRef = _messagesCollection.doc(docId);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (snapshot.get(MessageField.IS_GROUP) == true) {
        for (int i = 0; i < mem.length; i++) {
          if (mem[i][MessageField.MEMBER_UID] == uId) {
            mem[i][MessageField.MEMBER_UNREAD_COUNT] = 0;
            break;
          }
        }
        docRef.update({MessageField.MEMBERS: mem});
      } else {
        print(uId);
        print(snapshot.get(MessageField.SENDER_ID));
        if (snapshot.get(MessageField.SENDER_ID) == uId) {
          docRef.update({MessageField.SENDER_UNREAD: 0});
        } else {
          docRef.update({MessageField.RECIEVER_UNREAD: 0});
        }
      }
    });
  }

//............
//............ Get message request status
  Stream<Messagemodel> getMessageRequest(String docId) {
    return _messagesCollection
        .doc(docId)
        .snapshots()
        .map((DocumentSnapshot document) {
      return Messagemodel.fromJson(document.data() as Map<String, dynamic>);
    });
  }

//............ Send message
  Future<void> sendMessage(String docId, Chatmodel chatmodel) async {
    final batch = FirebaseFirestore.instance.batch();
    try {
      final docRef = _messagesCollection.doc(docId);
      DocumentSnapshot messageSnapshot = await docRef.get();
      if (chatmodel.type == 'image') {
        String? image = await uploadChatImageToFirebase(
            docId,
            chatmodel.message!,
            chatmodel.id!,
            chatmodel.time!,
            messageSnapshot);
        chatmodel.message = image;
      }

      CollectionReference chatCollection =
          _messagesCollection.doc(docId).collection(Collections.CHAT);
      batch.set(chatCollection.doc(), chatmodel.toJson());

      CollectionReference messageCollection = _messagesCollection;
      batch.update(messageCollection.doc(docId), {
        MessageField.LAST_MESSAGE:
            chatmodel.type == 'image' ? 'Photo' : chatmodel.message,
        MessageField.TIME_STAMP: chatmodel.time,
      });

      if (messageSnapshot.get(MessageField.IS_GROUP) == true) {
        for (int i = 0; i < mem.length; i++) {
          if (mem[i][MessageField.MEMBER_UID] != chatmodel.id) {
            int current = mem[i][MessageField.MEMBER_UNREAD_COUNT];
            mem[i][MessageField.MEMBER_UNREAD_COUNT] = current + 1;
          }
        }
        batch.update(docRef, {MessageField.MEMBERS: mem});
      } else {
        if (messageSnapshot.get(MessageField.SENDER_ID) == chatmodel.id) {
          batch.update(
              docRef, {MessageField.RECIEVER_UNREAD: FieldValue.increment(1)});
        } else {
          batch.update(
              docRef, {MessageField.SENDER_UNREAD: FieldValue.increment(1)});
        }
      }
      await batch.commit();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

//............ Upload chat images
  Future<String?> uploadChatImageToFirebase(String docId, String imagePath,
      String uId, String time, DocumentSnapshot snapshot) async {
    try {
      Reference storageReference;
      if (snapshot.get(MessageField.IS_GROUP) == true) {
        storageReference = _storage.ref().child('group/$docId/chat/$uId/$time');
      } else {
        storageReference = _storage.ref().child('singlechat/$docId/$uId/$time');
      }
      await storageReference.putFile(File(imagePath));
      final downloadUrl = await storageReference.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

//............ Get group members
  Stream<List<GroupMemberModel>> getGroupMembers(String docId, String userId) {
    try {
      return _messagesCollection
          .doc(docId)
          .snapshots()
          .map((DocumentSnapshot snapshot) {
        bool iAmAdmin = false;
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List memberlst = data[MessageField.MEMBERS];
        Map<String, dynamic>? userData;

        for (var item in memberlst) {
          if (item[MessageField.MEMBER_UID] == userId &&
              item[MessageField.IS_ADMIN] == true) {
            userData = item;
            break;
          }
        }
        return memberlst.map((item) {
          return userData != null
              ? GroupMemberModel.fromJson(item, true)
              : GroupMemberModel.fromJson(item, false);
        }).toList();
      });
    } catch (e) {
      rethrow;
    }
  }

//........... Get Group detail
  Future<GroupDetailModel> getGroupDetails(String docId, String myId) async {
    try {
      bool isAdmin = false;
      DocumentSnapshot snapshot = await _messagesCollection.doc(docId).get();
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      mem = data[MessageField.MEMBERS];
      for (var val in mem) {
        if (val[MessageField.MEMBER_UID] == myId) {
          isAdmin = val[MessageField.IS_ADMIN];
          break;
        }
      }
      return GroupDetailModel.fromJson(data, isAdmin);
    } catch (e) {
      rethrow;
    }
  }

//........... Update Group detail
  Future<bool> updateGroupName(
    String docId,
    String name,
  ) async {
    try {
      DocumentReference ref = _messagesCollection.doc(docId);
      await ref.update({
        MessageField.GROUP_NAME: name,
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateGroupAbout(
    String docId,
    String about,
  ) async {
    try {
      DocumentReference ref = _messagesCollection.doc(docId);

      await ref.update({
        MessageField.ABOUT_GROUP: about,
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> updateGroupImage(
    String docId,
    String imagePath,
  ) async {
    try {
      DocumentReference ref = _messagesCollection.doc(docId);

      String? image = await uploadImageToFirebase(docId, imagePath);
      await ref.update({MessageField.GROUP_IMG: image});

      return image!;
    } catch (e) {
      return '';
    }
  }

//........... Upload Group image
  Future<String?> uploadImageToFirebase(String docId, String imagePath) async {
    try {
      Reference storageReference = _storage.ref().child('group/$docId/$docId');

      await storageReference.putFile(File(imagePath));
      final downloadUrl = await storageReference.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

//........... Make Group Admin
  Future<void> makeGroupAdmin(
      String docId, String memberId, bool isAdmin) async {
    final docRef = _messagesCollection.doc(docId);
    db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      List memberLst = snapshot.get(MessageField.MEMBERS);
      for (var data in memberLst) {
        if (data[MessageField.MEMBER_UID] == memberId) {
          data[MessageField.IS_ADMIN] = isAdmin;
        }
      }
      transaction.update(docRef, {MessageField.MEMBERS: memberLst});
    });
  }

//........... Retrieve user for start new chat
  // Stream<List<UserModel>> getUsers(String name) {
  //   try {
  //     return db
  //         .collection('USER')
  //         .where('user name', isEqualTo: name)
  //         .snapshots()
  //         .map((snapshot) => snapshot.docs.map((doc) {
  //               Map<String, dynamic> data = doc.data();
  //               return UserModel.fromMap(data);
  //             }).toList());
  //   } catch (e) {
  //     print('Error: $e');
  //     rethrow;
  //   }
  // }

//...... foew now only for add new group member (make same for getting users for start new chat)
  Future<List<UserModel>> getUsers(String name) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection('USER')
          .where('user name', isGreaterThanOrEqualTo: name)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

//........... Start new chat
  Future<String> startNewChat(
      List ids, String senderName, String recieverName) async {
    if (await areIdsMatching(ids) != '') {
      print('No data added because IDs match');
      // Do not add data and return an indication that no data was added
      return areIdsMatching(ids);
    }
    Map<String, dynamic> data = {
      MessageField.ID: '',
      MessageField.IS_GROUP: false,
      MessageField.LAST_MESSAGE: TempLanguage.messageRequest,
      MessageField.MEMBER_IDS: ids,
      MessageField.RECIEVER_ABOUT: '',
      MessageField.RECIEVER_ID: ids.last,
      MessageField.RECIEVER_IMG: '',
      MessageField.RECIEVER_NAME: recieverName,
      MessageField.RECIEVER_UNREAD: 1,
      MessageField.SENDER_ABOUT: '',
      MessageField.SENDER_ID: ids.first,
      MessageField.SENDER_IMG: '',
      MessageField.SENDER_NAME: senderName,
      MessageField.SENDER_UNREAD: 0,
      MessageField.TIME_STAMP: '',
      MessageField.REQUEST_STATUS: RequestStatusEnum.pending.name
    };

    DocumentReference documentReference = await _messagesCollection.add(data);
    String documentId = documentReference.id;

    // Update the 'id' field in the model with the document ID
    _messagesCollection.doc(documentId).update({MessageField.ID: documentId});
    return documentId;
  }

  //........... Matching ids
  Future<String> areIdsMatching(List ids) async {
    // Perform a query to check if any document has the same IDs
    var resultOriginalOrder = await _messagesCollection
        .where(MessageField.IS_GROUP, isEqualTo: false)
        .where(MessageField.MEMBER_IDS, isEqualTo: ids)
        .get();
    List reversedIds = List.from(ids.reversed);
    var resultReversedOrder = await _messagesCollection
        .where(MessageField.IS_GROUP, isEqualTo: false)
        .where(MessageField.MEMBER_IDS, isEqualTo: reversedIds)
        .get();
    if (resultOriginalOrder.docs.isNotEmpty) {
      return resultOriginalOrder.docs.first.id;
    } else if (resultReversedOrder.docs.isNotEmpty) {
      return resultReversedOrder.docs.first.id;
    } else {
      return '';
    }
    //  return resultOriginalOrder.docs.isNotEmpty ||
    // resultReversedOrder.docs.isNotEmpty;
  }

  //........... Start new group chat
  Future<String> startNewGroupChat(List ids, List members) async {
    Map<String, dynamic> data = {
      MessageField.ABOUT_GROUP: '',
      MessageField.GROUP_IMG: '',
      MessageField.GROUP_NAME: '',
      MessageField.ID: '',
      MessageField.IS_GROUP: true,
      MessageField.LAST_MESSAGE: '',
      MessageField.MEMBER_IDS: ids,
      MessageField.MEMBERS: members,
      MessageField.TIME_STAMP: ''
    };

    DocumentReference documentReference = await _messagesCollection.add(data);
    String documentId = documentReference.id;

    // Update the 'id' field in the model with the document ID
    _messagesCollection.doc(documentId).update({MessageField.ID: documentId});
    return documentId;
  }

  //........... Update request status
  Future<void> updateRequestStatus(
      String docId, String status, String msg, int unread) async {
    try {
      DocumentReference ref = _messagesCollection.doc(docId);
      await ref.update({
        MessageField.REQUEST_STATUS: status,
        MessageField.RECIEVER_UNREAD: unread,
        MessageField.LAST_MESSAGE: msg
      });
    } catch (e) {
      rethrow;
    }
  }

  //........... Add new member
  Future<bool> addNewMember(List ids, List members, String docId) async {
    try {
      Map<String, dynamic> data = {
        MessageField.MEMBER_IDS: FieldValue.arrayUnion(ids),
        MessageField.MEMBERS: FieldValue.arrayUnion(members),
      };

      await _messagesCollection.doc(docId).update(data);

      return true;
    } catch (e) {
      print("Error updating document: $e");

      // Return false to indicate that the update was not successful
      return false;
    }
  }

  //........... Remove new member
  Future<void> removeMember(String id, docId) async {
    try {
      // Remove id from memberids array
      await _messagesCollection.doc(docId).update({
        MessageField.MEMBER_IDS: FieldValue.arrayRemove([id]),
      });
      // Get the current array of map data
      DocumentSnapshot documentSnapshot =
          await _messagesCollection.doc(docId).get();
      List<Map<String, dynamic>> currentData = List<Map<String, dynamic>>.from(
          documentSnapshot[MessageField.MEMBERS] ?? []);
      // Find the index of the map with the specified ID
      int indexToRemove =
          currentData.indexWhere((map) => map[MessageField.MEMBER_UID] == id);
      if (indexToRemove != -1) {
        // Remove the map from the array
        currentData.removeAt(indexToRemove);
        // Update the document with the modified array
        await _messagesCollection.doc(docId).update({
          MessageField.MEMBERS: currentData,
        });
      }
    } catch (e) {
      rethrow;
    }
  }

//............. get device token
  Future<String> getDeviceToken(String id) async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('USER').doc(id);

    DocumentSnapshot userSnapshot = await userRef.get();
    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>;
    List<dynamic>? deviceTokens = userData[UserKey.DEVICE_TOKEN];
    return deviceTokens!.first;
  }
}
