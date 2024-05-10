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
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

import '../controllers/Messages/firestore_pagination.dart';
import '../model/Message and Group Message Model/message_model.dart';

// List<dynamic> mem = [];

class MessageService {
  int unreadCount = 0;
  final db = FirebaseFirestore.instance;
  final CollectionReference _messagesCollection = FirebaseFirestore.instance.collection(Collections.MESSAGES);
  final FirebaseStorage _storage = FirebaseStorage.instance;

  FirestoreQueryBuilder<Messagemodel> buildChatMessageQueryBuilder(String myId, DocumentSnapshot? lastVisible) {
    Query query =
        _messagesCollection.where(MessageField.MEMBER_IDS, arrayContains: myId).orderBy('timestamp', descending: true);

    if (lastVisible != null) {
      query = query.startAfterDocument(lastVisible);
    }

    return FirestoreQueryBuilder<Messagemodel>(query);
  }

  FirestoreQueryBuilder<Chatmodel> buildConversationQueryBuilder(String docId, DocumentSnapshot? lastVisible) {
    Query query =
        _messagesCollection.doc(docId).collection(Collections.CHAT).orderBy(ChatField.TIME_STAMP, descending: true);

    if (lastVisible != null) {
      query = query.startAfterDocument(lastVisible);
    }

    return FirestoreQueryBuilder<Chatmodel>(query);
  }

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

              // if(data[MessageField.TIME_STAMP] is !Timestamp) {
              //   return Messagemodel(
              //     showMessageTile: false
              //   );
              // }

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
                      : (doc.data()[ChatField.TIME_STAMP] is !Timestamp
                         ? convertDateToTimeStamp(doc.data()[ChatField.TIME_STAMP]).compareTo(messageTimeStamp) > 0
                         : doc.data()[ChatField.TIME_STAMP].compareTo(messageTimeStamp) > 0);
               }) // Filter messages by timestamp
                .map<Chatmodel>((doc) {
              // updateLastSeen(docId, uId);
              updateUnreadCount(docId, uId, mem);
              readReceipts(docId, uId);
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

  // Stream<List<Chatmodel>> getNewConversation(String docId, String uId, List mem) {
  //   return _messagesCollection
  //       .doc(docId)
  //       .collection(Collections.CHAT)
  //       .orderBy(ChatField.TIME_STAMP, descending: true)
  //       .snapshots()
  //       .asyncMap((querySnapshot) async {
  //     List<Chatmodel> chatModels = [];
  //     bool excludeMessage = false;
  //     // updateLastSeen(docId, uId);
  //     updateUnreadCount(docId, uId, 0, mem);
  //     readReceipts(docId, uId);
  //     return chatModels;
  //   });
  // }

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
          print('wwwwwww: $data');
          print('wwwwwww: $status');
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
      print('Error fetching online status: $e');
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
  Future<void> updateDelete(String docId, String userId) async {
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
        // await _messagesCollection.doc(docId).set({MessageField.DELETE_IDS: deleteIds}, SetOptions(merge: true));
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
      FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (snapshot.get(MessageField.SENDER_ID) == uId) {
          docRef.update({'senderStatus': status});
        } else {
          docRef.update({'receiverStatus': status});
        }
      });
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

    // QuerySnapshot subcollectionSnapshot = await subcollectionRef.get();
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
  Future<void> updateUnreadCount(String docId, String uId, List mem) async {
    final docRef = _messagesCollection.doc(docId);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (snapshot.get(MessageField.IS_GROUP) == true && mem.isNotEmpty) {
        for (int i = 0; i < mem.length; i++) {
          if (mem[i][MessageField.MEMBER_UID] == uId) {
            print("------------>><${mem[i][MessageField.MEMBER_UID]}");
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
  Future<bool> readReceipts(String messageDoc, String uid) async {
    try {
      final querySnapshot = await _messagesCollection
          .doc(messageDoc)
          .collection(Collections.CHAT)
          .where('id', isNotEqualTo: uid)
          .where('isRead', isEqualTo: null)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (final doc in querySnapshot.docs) {
          final chatModel = Chatmodel.fromJson(doc.data());
          chatModel.isRead = true;
          await doc.reference.update(chatModel.toJson());
        }
        return true;
      } else {
        log("🟢🟢🟢🟢🟢DOCS ARE NULL🟢🟢🟢🟢🟢");
        return false; // No documents found where isRead is false
      }
    } catch (error) {
      print("🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢Error updating chat document models:🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢 $error");
      return false;
    }
  }

//............ Get message request status
  Stream<Messagemodel> getMessageRequest(String docId) {
    return _messagesCollection.doc(docId).snapshots().map((DocumentSnapshot document) {
      return Messagemodel.fromJson(document.data() as Map<String, dynamic>);
    });
  }

//............ Send message
  Future<DocumentSnapshot?> sendMessage(String docId, Chatmodel chatmodel, List mem) async {
    final batch = FirebaseFirestore.instance.batch();

    print("member$mem");
    final docRef = _messagesCollection.doc(docId);
    DocumentSnapshot messageSnapshot = await docRef.get();
    if (chatmodel.type == 'image') {
      var image = await uploadChatImageToFirebase(
          docId, chatmodel.message!, chatmodel.id!, chatmodel.time!.microsecondsSinceEpoch.toString(), messageSnapshot, chatmodel.thumbnail!);
      chatmodel.message = image['original'];
      chatmodel.thumbnail = image['thumbnail'];
    }

    CollectionReference chatCollection = _messagesCollection.doc(docId).collection(Collections.CHAT);

    // Get a reference to the newly added document
    DocumentReference newDocumentRef = chatCollection.doc();
    batch.set(newDocumentRef, chatmodel.toJson());

    CollectionReference messageCollection = _messagesCollection;
    //   update lastseen and timestamp
    batch.update(messageCollection.doc(docId), {
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
      batch.update(docRef, {MessageField.MEMBERS: mem});
    } else {
      if (messageSnapshot.get(MessageField.SENDER_ID) == chatmodel.id) {
        batch.update(docRef, {MessageField.RECIEVER_UNREAD: FieldValue.increment(1)});
      } else {
        batch.update(docRef, {MessageField.SENDER_UNREAD: FieldValue.increment(1)});
      }
    }
    await batch.commit();

    // Fetch and return the snapshot of the newly added document
    DocumentSnapshot newDocumentSnapshot = await newDocumentRef.get();
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
    // if (await areIdsMatching(ids) != '') {
    //   print('No data added because IDs match');
    //   // Do not add data and return an indication that no data waSs added
    //   return {'NewChat': 'No', 'docId': areIdsMatching(ids)};
    // }
    Map<String, dynamic> data = {
      MessageField.ID: '',
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
  Future<Map<String, String>> startNewGroupChat(
      List ids, List members, String groupName, groupInfo, String groupImage) async {
    print('members $members');
    Map<String, dynamic> data = {
      MessageField.ABOUT_GROUP: groupInfo,
      MessageField.GROUP_IMG: '',
      MessageField.GROUP_NAME: groupName,
      MessageField.ID: '',
      MessageField.IS_GROUP: true,
      MessageField.LAST_MESSAGE: '',
      MessageField.MEMBER_IDS: ids,
      MessageField.MEMBERS: members,
      //MessageField.TIME_STAMP: DateTime.now().toString(),
      MessageField.TIME_STAMP: Timestamp.now(),
    };

    DocumentReference documentReference = await _messagesCollection.add(data);
    String documentId = documentReference.id;

    String? image = '';
    groupImage != '' ? image = await uploadImageToFirebase(documentId, groupImage) : image = '';

    // Update the 'id' field in the model with the document ID
    _messagesCollection.doc(documentId).update({MessageField.ID: documentId, MessageField.GROUP_IMG: image});
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

  // Future<bool> removeCurrentUserFromMemberIds(String docID) async {
  //   String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  //   CollectionReference messagesCollection = FirebaseFirestore.instance.collection(Collections.MESSAGES);
  //   DocumentReference documentReference = messagesCollection.doc(docID);
  //   DocumentSnapshot documentSnapshot = await documentReference.get();
  //   List<dynamic> memberIds = documentSnapshot[MessageField.MEMBER_IDS];
  //   memberIds.remove(currentUserUid);
  //   await documentReference.update({MessageField.MEMBER_IDS: memberIds});
  //   return true;
  // }

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
      //.....Remove ID from DELETE_IDS array
      // List<Map<String, dynamic>> deleteMapData =
      //     List<Map<String, dynamic>>.from(documentSnapshot[MessageField.DELETE_IDS] ?? []);
      // Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      // int indexToRemoveDelete = deleteMapData
      //     .indexWhere((map) => map.containsKey(MessageField.MEMBER_UID) && map[MessageField.MEMBER_UID] == id);
      // if (indexToRemoveDelete != -1) {
      //   deleteMapData.removeAt(indexToRemoveDelete);
      //   batch.update(_messagesCollection.doc(docId), {
      //     MessageField.DELETE_IDS: deleteMapData,
      //   });
      // }
      await batch.commit();
    } catch (e) {
      log("Error is --------------------------> $e");
      rethrow;
    }
  }

  //........... Remove new member
  // Future<void> removeMember(String id, docId) async {
  //   print("doc id is: =========================> $docId");
  //   try {
  //     await _messagesCollection.doc(docId).update({
  //       MessageField.MEMBER_IDS: FieldValue.arrayRemove([id]),
  //     });
  //     DocumentSnapshot documentSnapshot = await _messagesCollection.doc(docId).get();
  //     List<Map<String, dynamic>> currentData =
  //         List<Map<String, dynamic>>.from(documentSnapshot[MessageField.MEMBERS] ?? []);
  //     int indexToRemove = currentData.indexWhere((map) => map[MessageField.MEMBER_UID] == id);
  //     if (indexToRemove != -1) {
  //       currentData.removeAt(indexToRemove);
  //       await _messagesCollection.doc(docId).update({
  //         MessageField.MEMBERS: currentData,
  //       });
  //     }
  //   } catch (e) {
  //     log("Error is --------------------------> $e");
  //     rethrow;
  //   }
  // }

//............. get device token
  Future<List<dynamic>> getDeviceToken(String id) async {
    DocumentReference userRef = FirebaseFirestore.instance.collection('USER').doc(id);

    DocumentSnapshot userSnapshot = await userRef.get();
    Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>;
    // print(userData[UserKey.DEVICE_TOKEN]);
    //
    // print(userData[UserKey.DEVICE_TOKEN].runtimeType);
    // print(userData[UserKey.DEVICE_TOKEN]);

    List<dynamic>? deviceTokens = userData[UserKey.DEVICE_TOKEN];
    return deviceTokens ?? [];
  }
}
