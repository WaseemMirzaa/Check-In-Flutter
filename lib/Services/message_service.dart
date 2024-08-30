// ignore_for_file: unused_local_variable, avoid_print

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/chat_model.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/group_detail_model.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/group_member_model.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/utils/Constants/enums.dart';
import 'package:check_in/utils/common.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../firebase_options.dart';
import '../model/Message and Group Message Model/message_model.dart';

// List<dynamic> mem = [];

class MessageService {
  int unreadCount = 0;
  final db = FirebaseFirestore.instance;
  final CollectionReference _messagesCollection = FirebaseFirestore.instance.collection(Collections.MESSAGES);
  final FirebaseStorage _storage = FirebaseStorage.instance;
//............ Get Message
  Stream<List<Messagemodel>> getChatMessage(String myId) {
    List<dynamic> mem = [];
    return _messagesCollection
        .where(MessageField.MEMBER_IDS, arrayContains: myId)
        .orderBy(MessageField.TIME_STAMP, descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.map<Messagemodel>((doc) {
              num unread = 0;
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              bool checkMyId = false;
              bool checkDeleteStatus = true;
              bool showMessagetile = false;
              String name, imagepath, yourname = '';
              List delete = [];
              if (data[MessageField.IS_GROUP] == true) {
                name = data[MessageField.GROUP_NAME];
                imagepath = data[MessageField.GROUP_IMG];
                mem = data[MessageField.MEMBERS];
                yourname = data[MessageField.GROUP_NAME];
                if (data.containsKey(MessageField.DELETE_IDS)) {
                  delete = data[MessageField.DELETE_IDS];
                }
                for (var val in data[MessageField.MEMBERS]) {
                  if (val[MessageField.MEMBER_UID] == myId) {
                    unread = val[MessageField.MEMBER_UNREAD_COUNT];
                    checkMyId = true;
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
                checkMyId = data[MessageField.RECIEVER_ID] == myId &&
                        data[MessageField.REQUEST_STATUS] == RequestStatusEnum.delete.name
                    ? false
                    : true;
                if (data.containsKey(MessageField.DELETE_IDS)) {
                  delete = data[MessageField.DELETE_IDS];
                }
              }
              if (delete.isNotEmpty) {
                for (var del in delete) {
                  if (del[MessageField.MEMBER_UID] == myId && del[MessageField.IS_DELETED] == true) {
                    checkDeleteStatus = false;
                    break;
                  }
                }
              }
              showMessagetile = checkMyId && checkDeleteStatus ? true : false;
              return Messagemodel.fromJson(doc.data() as Map<String, dynamic>,
                  name: name,
                  deleteIds: delete,
                  image: imagepath,
                  unread: unread,
                  showMessageTile: showMessagetile,
                  yourName: yourname);
            }).toList());
  }

//............ Get Single Message
  Future<Messagemodel> getSingleMessage(String docId, String uId) async {
    DocumentSnapshot documentSnapshot = await _messagesCollection.doc(docId).get();

    if (documentSnapshot.exists) {
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      String imagepath = '';
      if (data[MessageField.IS_GROUP] == true) {
        imagepath = data[MessageField.GROUP_IMG];
      } else {
        imagepath =
            data[MessageField.SENDER_ID] == uId ? data[MessageField.RECIEVER_IMG] : data[MessageField.SENDER_IMG];
      }
      return Messagemodel.fromJson(data, image: imagepath);
    } else {
      log('Document not exist');
      throw Exception('Document does not exist for ID: $docId');
    }
  }

//............ Get conversations
  /// [GetConversation]
  ///
  /// This method is fetching all the messages between users.
  Stream<List<Chatmodel>> getConversation(String docId, String uId, List mem, Timestamp? messageTimeStamp) {
    return _messagesCollection
        .doc(docId)
        .collection(Collections.CHAT)
        .orderBy(ChatField.TIME_STAMP, descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
                .where((doc) {
                  return messageTimeStamp == null
                      ? true
                      : doc.data()[ChatField.TIME_STAMP].compareTo(messageTimeStamp) > 0;
               }) // Filter messages by timestamp
                .map<Chatmodel>((doc) {
      calculateTimeDifference('GetConversation Stream Start');
               updateUnreadCount(docId, uId, mem);

              if (doc.data()['isRead'] == null && doc.data()['id'] != uId) {
                readReceipts(docId, doc.id);
              }
              calculateTimeDifference('GetConversation Stream End');
              return Chatmodel.fromJson(doc.data(), docID: doc.id);
            }).toList());
  }

  Future<String?> getLastMessage(String docId, String uId, Timestamp? messageTimeStamp) async {

    final result = await _messagesCollection
        .doc(docId)
        .collection(Collections.CHAT)
        .orderBy(ChatField.TIME_STAMP, descending: true)
        .limit(1)
        .get();

    if (result.docs.isNotEmpty) {
      final doc = result.docs.first;
      if (messageTimeStamp == null || doc.data()[ChatField.TIME_STAMP].compareTo(messageTimeStamp) > 0) {
        final chat = Chatmodel.fromJson(doc.data(), docID: doc.id);
        return chat.message;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }


  Future<Timestamp?> getDeleteTimeStamp(String docId, String uId) async {
    DocumentSnapshot messageSnapshot = await _messagesCollection.doc(docId).get();
    Map<String, dynamic> data = messageSnapshot.data() as Map<String, dynamic>;
    Timestamp? deleteTimestamp;

    if (messageSnapshot.exists && data.containsKey(MessageField.DELETE_IDS)) {
      List<dynamic> deleteIds = data[MessageField.DELETE_IDS];
      for (var deleteId in deleteIds) {
        if (deleteId.containsKey(MessageField.MEMBER_UID) &&
            deleteId[MessageField.MEMBER_UID] == uId &&
            deleteId.containsKey(MessageField.DELETE_TIMESTAMP)) {
          deleteTimestamp = deleteId[MessageField.DELETE_TIMESTAMP];
        }
      }
    }
    return deleteTimestamp;
  }

  // Function to fetch the online status of a user
  Future<String> getOnlineStatus(String docId) async {
    try {
      DocumentSnapshot snapshot = await _messagesCollection.doc(docId).get();
      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('senderStatus')) {
          String status = data['senderStatus'];
          if (status == 'Online') {
            return 'Online';
          } else if (status.isNotEmpty) {
            DateTime lastSeen = DateTime.parse(status);
            return 'Last Seen ${DateFormat('hh:mm a').format(lastSeen)}';
          }
        }
      }
      return '';
    } catch (e) {
      return '';
    }
  }

//.............. Delete message
  Future deleteMessage(String docID, String userID) async {
    DocumentReference docRef = _messagesCollection.doc(docID);
    DocumentSnapshot snapshot = await docRef.get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    if (snapshot.exists) {
      List<dynamic> deleteIds = data[MessageField.DELETE_IDS] ?? [];

      bool found = false;

      for (int i = 0; i < deleteIds.length; i++) {
        if (deleteIds[i][MessageField.MEMBER_UID] == userID) {
          deleteIds[i][MessageField.IS_DELETED] = true;
          deleteIds[i][MessageField.DELETE_TIMESTAMP] = Timestamp.now();
          found = true;
          break;
        }
      }

      if (!found) {
        Map<String, dynamic> userData = {
          MessageField.MEMBER_UID: userID,
          MessageField.IS_DELETED: true,
          MessageField.DELETE_TIMESTAMP: Timestamp.now()
        };
        deleteIds.add(userData);
      }

      await _messagesCollection.doc(docID).set({MessageField.DELETE_IDS: deleteIds}, SetOptions(merge: true));
    }
  }

//............ Update delete data array
  ///Purpose of this code is to make deleted user undeleted
  /// (It means they can again send and receive messages)
  Future<void> updateDelete(String docId, String userId) async {
    calculateTimeDifference('Start Update Delete');

    try {
      DocumentReference docRef = _messagesCollection.doc(docId);
      DocumentSnapshot snapshot = await docRef.get();
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      if (snapshot.exists) {
        List<dynamic> deleteIds = data[MessageField.DELETE_IDS] ?? [];

        for (int i = 0; i < deleteIds.length; i++) {
          if (deleteIds[i][MessageField.IS_DELETED] == true) {
            deleteIds[i][MessageField.IS_DELETED] = false;
          }
        }
        if (data.containsKey(MessageField.DELETE_IDS)) {
          await _messagesCollection.doc(docId).set({MessageField.DELETE_IDS: deleteIds}, SetOptions(merge: true));
        }
        // await _messagesCollection.doc(docId).set({MessageField.DELETE_IDS: deleteIds}, SetOptions(merge: true));
      }
    } catch (error) {
      print("Error updating deleteIds: $error");
    }
    calculateTimeDifference('End Update Delete');

  }

  Future<void> updateUserDelete(String docId, String userId) async {
    try {
      DocumentReference docRef = _messagesCollection.doc(docId);
      DocumentSnapshot snapshot = await docRef.get();
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      if (snapshot.exists) {
        List<dynamic> deleteIds = data[MessageField.DELETE_IDS] ?? [];

        for (int i = 0; i < deleteIds.length; i++) {
          if (deleteIds[i][MessageField.IS_DELETED] == true && deleteIds[i][MessageField.MEMBER_UID] == userId) {
            deleteIds[i][MessageField.IS_DELETED] = false;
            break;
          }
        }
        if (data.containsKey(MessageField.DELETE_IDS)) {
          await _messagesCollection.doc(docId).set({MessageField.DELETE_IDS: deleteIds}, SetOptions(merge: true));
        }
      }
    } catch (error) {
      print(" Error updating deleteIds: ${error.toString()}");
    }
  }

  // Function to update the online status of a user
  Future<void> updateOnlineStatus(String docId, String status, String uId) async {
    try {
      print(docId);
      print(uId);
      final docRef = _messagesCollection.doc(docId);

      final snapshot = await docRef.get();
      final data = snapshot.data() as Map<String, dynamic>;
      if (data.containsKey(MessageField.SENDER_ID)) {
        if (snapshot.get(MessageField.SENDER_ID) == uId) {
          await docRef.update({'senderStatus': status});
        } else {
          await docRef.update({'receiverStatus': status});
        }
      }
      print('Online status updated successfully for user $docId');
    } catch (e) {
      print('Error updating online status: $e');
    }
  }


//............ Update last Seen
  Future<void> updateLastSeen(String docId, String uid) async {
    print(uid);
    final docRef = _messagesCollection.doc(docId);
    final CollectionReference subcollectionRef = docRef.collection(Collections.CHAT);

    QuerySnapshot subcollectionSnapshot = await subcollectionRef.where('id', isNotEqualTo: uid).get();

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
  /// [UpdateUnreadCount]
  ///
  /// This method update the unread messages of the users in group and one-to-one chat.
  Future<void> updateUnreadCount(String docId, String uId, List mem) async {
    calculateTimeDifference('updateUnReadCount');
    final start = DateTime.now();
    final docRef = _messagesCollection.doc(docId);

    final snapshot = await docRef.get();
    if (snapshot.get(MessageField.IS_GROUP) == true && mem.isNotEmpty) {
      for (int i = 0; i < mem.length; i++) {
        if (mem[i][MessageField.MEMBER_UID] == uId) {
          mem[i][MessageField.MEMBER_UNREAD_COUNT] = 0;
          break;
        }
      }
      await docRef.update({MessageField.MEMBERS: mem});
    } else {
      final data = snapshot.data() as Map<String, dynamic>;

      if (data.containsKey(MessageField.SENDER_ID)) {
        if (snapshot.get(MessageField.SENDER_ID) == uId) {
          await docRef.update({MessageField.SENDER_UNREAD: 0});
        } else {
          await docRef.update({MessageField.RECIEVER_UNREAD: 0});
        }
      }
    }
  }

  //.............. Delete Chat Function
  Future<bool> deleteChatAndUpdateModel(String messageDoc, String docID) async {
    try {
      final docSnapshot = await _messagesCollection.doc(messageDoc).collection(Collections.CHAT).doc(docID).get();

      if (docSnapshot.exists) {
        final chatModel = Chatmodel.fromJson(docSnapshot.data()!);
        chatModel.isDelete = true;
        chatModel.message = "message deleted";

        await _messagesCollection.doc(messageDoc).collection(Collections.CHAT).doc(docID).update(chatModel.toJson());

        return true;
      } else {
        // Document does not exist
        return false;
      }
    } catch (error) {
      print("Error updating chat document model: $error");
      return false;
    }
  }

  // ................ READ RECEIPTS
  ///[ReadReceipts]
  ///
  /// This method is use to update the unread message status to true
  void readReceipts(String docId, String messageId) async {
    calculateTimeDifference('Start Read Receipts');
    await _messagesCollection
        .doc(docId)
        .collection(Collections.CHAT)
        .doc(messageId)
        .update({
      'isRead': true
    });
    calculateTimeDifference('End Read Receipts');
  }

//............ Get message request status
  Stream<Messagemodel> getMessageRequest(String docId) {
    return _messagesCollection.doc(docId).snapshots().map((DocumentSnapshot document) {
      return Messagemodel.fromJson(document.data() as Map<String, dynamic>);
    });
  }


  Future<void> _isolateGetTheMostLikes(List<Object> args,) async {
    final rootIsolateToken = args[0] as RootIsolateToken;
    final messageSnapshot = args[1] as DocumentSnapshot;
    final mem = args[2] as List;
    final chatmodel = args[3] as Chatmodel;
    final docRef = args[4] as DocumentReference;

    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    if (messageSnapshot.get(MessageField.IS_GROUP) == true) {
      for (int i = 0; i < mem.length; i++) {
        if (mem[i][MessageField.MEMBER_UID] != chatmodel.id) {
          int current = mem[i][MessageField.MEMBER_UNREAD_COUNT];
          mem[i][MessageField.MEMBER_UNREAD_COUNT] = current + 1;
        }
      }
      await docRef.update({MessageField.MEMBERS: mem});
    } else {
      if (messageSnapshot.get(MessageField.SENDER_ID) == chatmodel.id) {
        await docRef.update({MessageField.RECIEVER_UNREAD: FieldValue.increment(1)});
      } else {
        await docRef.update({MessageField.SENDER_UNREAD: FieldValue.increment(1)});
      }
    }

  }

  Future<DocumentSnapshot?> sendMessage(String docId, Chatmodel chatmodel, List mem) async {

    calculateTimeDifference('Start Send Message');
    final docRef = _messagesCollection.doc(docId);
    DocumentSnapshot messageSnapshot = await docRef.get();

    if (chatmodel.type == 'image') {
      var image = await uploadChatImageToFirebase(
          docId, chatmodel.message!, chatmodel.id!, chatmodel.time!.microsecondsSinceEpoch.toString(), messageSnapshot, chatmodel.thumbnail!);
      chatmodel.message = image['original'];
      chatmodel.thumbnail = image['thumbnail'];
    }

    CollectionReference chatCollection = _messagesCollection.doc(docId).collection(Collections.CHAT);
    DocumentReference newDocumentRef = chatCollection.doc();

    await newDocumentRef.set(chatmodel.toJson());

    await _messagesCollection.doc(docId).update({
      MessageField.LAST_MESSAGE: chatmodel.type == 'image' ? 'Photo' : chatmodel.message,
      MessageField.TIME_STAMP: chatmodel.time,
    });

    if (messageSnapshot.get(MessageField.IS_GROUP) == true) {
      for (int i = 0; i < mem.length; i++) {
        if (mem[i][MessageField.MEMBER_UID] != chatmodel.id) {
          int current = mem[i][MessageField.MEMBER_UNREAD_COUNT];
          mem[i][MessageField.MEMBER_UNREAD_COUNT] = current + 1;
        }
      }
      await docRef.update({MessageField.MEMBERS: mem});
    } else {
      if (messageSnapshot.get(MessageField.SENDER_ID) == chatmodel.id) {
        await docRef.update({MessageField.RECIEVER_UNREAD: FieldValue.increment(1)});
      } else {
        await docRef.update({MessageField.SENDER_UNREAD: FieldValue.increment(1)});
      }
    }

    DocumentSnapshot newDocumentSnapshot = await newDocumentRef.get();
    calculateTimeDifference('End Send Message');
    return newDocumentSnapshot;
  }


//............ Upload chat images
  Future<Map<String, String>> uploadChatImageToFirebase(
       String docId, String imagePath, String uId, String time, DocumentSnapshot snapshot, String thumnail) async {
    try {
      Reference storageReference;
      Reference thumbnailStorageReference;
      if (snapshot.get(MessageField.IS_GROUP) == true) {
        storageReference = _storage.ref().child('group/$docId/chat/$uId/$time');
        thumbnailStorageReference = _storage.ref().child('group/$docId/chat/$uId/$time/thumbnail');
      } else {
        storageReference = _storage.ref().child('singlechat/$docId/$uId/$time');
        thumbnailStorageReference = _storage.ref().child('singlechat/$docId/$uId/$time/thumbnail');
      }
      await storageReference.putFile(File(imagePath));
      await thumbnailStorageReference.putFile(File(thumnail));
      final downloadUrl = await storageReference.getDownloadURL();
      final downloadThumbnailUrl = await thumbnailStorageReference.getDownloadURL();
      return {'original': downloadUrl, 'thumbnail': downloadThumbnailUrl};
    } catch (e) {
      log(e.toString());
      return {};
    }
  }

//............ Get group members
  Stream<List<GroupMemberModel>> getGroupMembers(String docId, String userId) {
    try {
      return _messagesCollection.doc(docId).snapshots().map((DocumentSnapshot snapshot) {
        bool iAmAdmin = false;
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List memberlst = data[MessageField.MEMBERS];
        Map<String, dynamic>? userData;

        for (var item in memberlst) {
          if (item[MessageField.MEMBER_UID] == userId && item[MessageField.IS_ADMIN] == true) {
            userData = item;
            break;
          }
        }
        return memberlst.map((item) {
          return userData != null ? GroupMemberModel.fromJson(item, true) : GroupMemberModel.fromJson(item, false);
        }).toList();
      });
    } catch (e) {
      rethrow;
    }
  }

//........... Get Group detail
  Future<GroupDetailModel> getGroupDetails(String docId, String myId) async {
    List mem;
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
  Future<void> makeGroupAdmin(String docId, String memberId, bool isAdmin) async {
    final docRef = _messagesCollection.doc(docId);

    final snapshot = await docRef.get();
    List memberLst = snapshot.get(MessageField.MEMBERS);

    for (var data in memberLst) {
      if (data[MessageField.MEMBER_UID] == memberId) {
        data[MessageField.IS_ADMIN] = isAdmin;
      }
    }

    await docRef.update({MessageField.MEMBERS: memberLst});
  }

  Future<List<UserModel>> getUsers(String name) async {
    try {
      QuerySnapshot querySnapshot = await db.collection('USER').where('user name', isGreaterThanOrEqualTo: name).get();

      return querySnapshot.docs.map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<List<DocumentSnapshot>> getUsersDocsWithPagination(
      String name, int resultsPerPage, DocumentSnapshot? lastDocument) async {
    try {
      Query query = db.collection(Collections.USER).where(UserKey.PARAMS, arrayContains: name).limit(resultsPerPage);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      QuerySnapshot querySnapshot = await query.get();

      return querySnapshot.docs;
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

//........... Start new chat
  Future<String> startNewChat(List ids, String senderName, String recieverName, String photoUrl, String UIimage) async {
    String documentId = _messagesCollection.doc().id;

    Map<String, dynamic> data = {
      MessageField.ID: documentId,
      MessageField.IS_GROUP: false,
      MessageField.LAST_MESSAGE: TempLanguage.messageRequest,
      MessageField.MEMBER_IDS: ids,
      MessageField.RECIEVER_ABOUT: '',
      MessageField.RECIEVER_ID: ids.last,
      MessageField.RECIEVER_IMG: photoUrl,
      MessageField.RECIEVER_NAME: recieverName,
      MessageField.RECIEVER_UNREAD: 1,
      MessageField.SENDER_ABOUT: '',
      MessageField.SENDER_ID: ids.first,
      MessageField.SENDER_IMG: UIimage,
      MessageField.SENDER_NAME: senderName,
      MessageField.SENDER_UNREAD: 0,
      //MessageField.TIME_STAMP: DateTime.now().toString(),
      MessageField.TIME_STAMP: Timestamp.now(),
      MessageField.REQUEST_STATUS: RequestStatusEnum.pending.name
    };

    await _messagesCollection.doc(documentId).set(data);
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
  Future<Map<String, String>> startNewGroupChat(
      List ids, List members, String groupName, groupInfo, String groupImage) async {

    String documentId = _messagesCollection.doc().id;

    Map<String, dynamic> data = {
      MessageField.ABOUT_GROUP: groupInfo,
      MessageField.GROUP_IMG: '',
      MessageField.GROUP_NAME: groupName,
      MessageField.ID: documentId,
      MessageField.IS_GROUP: true,
      MessageField.LAST_MESSAGE: '',
      MessageField.MEMBER_IDS: ids,
      MessageField.MEMBERS: members,
      //MessageField.TIME_STAMP: DateTime.now().toString(),
      MessageField.TIME_STAMP: Timestamp.now(),
    };


    await _messagesCollection.doc(documentId).set(data);
    //String documentId = documentReference.id;

    String? image = '';
    groupImage != '' ? image = await uploadImageToFirebase(documentId, groupImage) : image = '';

    // Update the 'id' field in the model with the document ID
    await _messagesCollection.doc(documentId).update({MessageField.GROUP_IMG: image});
    return {MessageField.ID: documentId, MessageField.GROUP_IMG: image ?? ''};
  }

  //........... Update request status
  Future<void> updateRequestStatus(String docId, String status, String msg, int unread, String uid) async {
    try {
      DocumentReference ref = _messagesCollection.doc(docId);

      await ref.update(
          {MessageField.REQUEST_STATUS: status, MessageField.RECIEVER_UNREAD: unread, MessageField.LAST_MESSAGE: msg});
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateCollection(String collectionName, String docID, Map<String, dynamic> list) async {
    try {
      await db.collection(collectionName).doc(docID).update(list);
      return true;
    } catch (e) {
      log("The error while Updatation is: $e");
      return false;
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

//................... Remove user/Left Group
  Future<void> removeGroupUser(String docId, String id) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    try {
      //.....Remove ID from MEMBER_IDS array
      batch.update(_messagesCollection.doc(docId), {
        MessageField.MEMBER_IDS: FieldValue.arrayRemove([id]),
      });
      //.....Remove ID from MEMBERS array
      DocumentSnapshot documentSnapshot = await _messagesCollection.doc(docId).get();
      List<Map<String, dynamic>> currentData =
          List<Map<String, dynamic>>.from(documentSnapshot[MessageField.MEMBERS] ?? []);
      int indexToRemove = currentData.indexWhere((map) => map[MessageField.MEMBER_UID] == id);
      if (indexToRemove != -1) {
        currentData.removeAt(indexToRemove);
        batch.update(_messagesCollection.doc(docId), {
          MessageField.MEMBERS: currentData,
        });
      }

      await batch.commit();
    } catch (e) {
      log("Error is --------------------------> $e");
      rethrow;
    }
  }


  Future<List<dynamic>> getDeviceToken(String id) async {
    DocumentReference userRef = FirebaseFirestore.instance.collection('USER').doc(id);

    DocumentSnapshot userSnapshot = await userRef.get();
    Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>;
    List<dynamic>? deviceTokens = userData[UserKey.DEVICE_TOKEN];
    return deviceTokens ?? [];
  }

  static void removeDeviceToken(String id, String token) async {
    try {
      DocumentReference userRef = FirebaseFirestore.instance.collection('USER').doc(id);
      await userRef.update(
        {
          'deviceToken': FieldValue.arrayRemove([token])
        }
      );
    } catch (e) {
      print(e);
    }
  }
}
