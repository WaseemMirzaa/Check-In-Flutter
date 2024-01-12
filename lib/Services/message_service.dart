// ignore_for_file: unused_local_variable, avoid_print

import 'dart:developer';
import 'dart:io';

import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/chat_model.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/group_detail_model.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/group_member_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../model/Message and Group Message Model/message_model.dart';
import '../utils/Constants/global_variable.dart';

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
              String name, imagepath = '';

              if (data[MessageField.IS_GROUP] == true) {
                name = data[MessageField.GROUP_NAME];
                imagepath = data[MessageField.GROUP_IMG];
                mem = data[MessageField.MEMBERS];
                for (var val in mem) {
                  if (val[MessageField.MEMBER_UID] == myId) {
                    unread = val[MessageField.MEMBER_UNREAD_COUNT];
                    break;
                  }
                }
              } else {
                name = data[MessageField.SENDER_ID] == myId
                    ? data[MessageField.RECIEVER_NAME]
                    : data[MessageField.SENDER_NAME];
                imagepath = data[MessageField.SENDER_ID] == myId
                    ? data[MessageField.RECIEVER_IMG]
                    : data[MessageField.SENDER_IMG];
                unread = data[MessageField.SENDER_ID] == myId
                    ? data[MessageField.SENDER_UNREAD]
                    : data[MessageField.RECIEVER_UNREAD];
              }
              return Messagemodel.fromJson(
                  doc.data() as Map<String, dynamic>, name, imagepath, unread);
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
              updateUnreadCount(docId, uId, 0);
              return Chatmodel.fromJson(doc.data());
            }).toList());
  }

//............ Update Unread Count
  Future<void> updateUnreadCount(
    String docId,
    String uId,
    num unreadval,
  ) async {
    final docRef = _messagesCollection.doc(docId);
    db.runTransaction((transaction) async {
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
        if (snapshot.get(MessageField.SENDER_ID) == uId) {
          docRef.update({MessageField.SENDER_UNREAD: 0});
        } else {
          docRef.update({MessageField.RECIEVER_UNREAD: 0});
        }
      }
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
  Stream<List<GroupMemberModel>> getGroupMembers(String docId) {
    try {
      return _messagesCollection
          .doc(docId)
          .snapshots()
          .map((DocumentSnapshot snapshot) {
        bool iAmAdmin = false;
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List memberlst = data[MessageField.MEMBERS];
        return memberlst.map((item) {
          if (item[MessageField.MEMBER_UID] == GlobalVariable.userid &&
              item[MessageField.IS_ADMIN] == true) {
            iAmAdmin = true;
          }

          return GroupMemberModel.fromJson(item, iAmAdmin);
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
  Future<bool> updateGroupdetail(
    String docId,
    String name,
    String about,
    String imagePath,
  ) async {
    try {
      DocumentReference ref = _messagesCollection.doc(docId);
      if (imagePath == '') {
        await ref.update({
          MessageField.ABOUT_GROUP: about,
          MessageField.GROUP_NAME: name,
        });
      } else {
        String? image = await uploadImageToFirebase(docId, imagePath);
        await ref.update({
          MessageField.ABOUT_GROUP: about,
          MessageField.GROUP_NAME: name,
          MessageField.GROUP_IMG: image
        });
      }
      return true;
    } catch (e) {
      return false;
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
  Future<void> makeGroupAdmin(String docId, String memberId) async {
    final docRef = _messagesCollection.doc(docId);
    db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      List memberLst = snapshot.get(MessageField.MEMBERS);
      for (var data in memberLst) {
        if (data[MessageField.MEMBER_UID] == memberId) {
          data[MessageField.IS_ADMIN] = true;
        }
      }
      transaction.update(docRef, {MessageField.MEMBERS: memberLst});
    });
  }
}
