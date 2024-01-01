// ignore_for_file: unused_local_variable, avoid_print

import 'package:check_in/model/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/message_model.dart';

List<dynamic> mem = [];

class MessageService {
  int unreadCount = 0;
  final db = FirebaseFirestore.instance;
  final CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('messages');

//............ Get Message
  Stream<List<Messagemodel>> getChatMessage(String myId) {
    return _messagesCollection
        .where('memberIds', arrayContains: myId)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.map<Messagemodel>((doc) {
              // fetchTotalUnreadCount('groupA');
              num unread = 0;
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              //

              String name, imagepath = '';

              if (data['isGroup'] == true) {
                name = data['groupName'];
                imagepath = data['groupImg'];

                mem = data['mem'];
                for (var val in mem) {
                  if (val['uid'] == myId) {
                    unread = val['unreadCount'];
                  }
                }
                // unread = data['members'][myId]['unreadCount'];
              } else {
                name = data['senderId'] == myId
                    ? data['recieverName']
                    : data['senderName'];
                imagepath = data['senderId'] == myId
                    ? data['recieverImg']
                    : data['senderImg'];
                unread = data['senderId'] == myId
                    ? data['senderUnread']
                    : data['recieverUnread'];
              }

              return Messagemodel.fromJson(
                  doc.data() as Map<String, dynamic>, name, imagepath, unread);
            }).toList());
  }

//............ Get conversations
  Stream<List<Chatmodel>> getConversation(String docId, String uId) {
    return _messagesCollection
        .doc(docId)
        .collection('chat')
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.map<Chatmodel>((doc) {
              updateUnreadCount(docId, uId);
              return Chatmodel.fromJson(doc.data());
            }).toList());
  }

//............ Update Unread Count
  Future<void> updateUnreadCount(
    String docId,
    String uId,
    // num unreadval,
  ) async {
    final docRef = _messagesCollection.doc(docId);
    db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (snapshot.get('isGroup') == true) {
        for (int i = 0; i < mem.length; i++) {
          if (mem[i]['uid'] == uId) {
            mem[i]['unreadCount'] = 0;
            break;
          }
        }
        docRef.update({'mem': mem});
      } else {
        if (snapshot.get('senderId') == uId) {
          docRef.update({
            'senderUnread':
                // unreadval==0?
                0
            // : FieldValue.increment(1)
          });
        } else {
          docRef.update({
            'recieverUnread':
                // unreadval== 0?
                0
            // :FieldValue.increment(1)
          });
        }
      }
    });
  }

////////////  fetch count
  Future<int> fetchTotalUnreadCount(String groupId) async {
    print('in fetch');
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('messages')
          .doc(groupId)
          .get();

      if (!snapshot.exists) {
        return 0;
      }

      List<dynamic> memArray = snapshot.data()!['mem'] ?? [];

      List<int> unreadCounts = memArray.map<int>((item) {
        return item['unreadCount'] ?? 0;
      }).toList();

      int totalCount = unreadCounts.reduce((value, element) => value + element);

      unreadCount = totalCount;
      print("***************************************$unreadCount");
      return totalCount;
    } catch (e) {
      print('Error fetching data: $e');
      return 0;
    }
  }

//............ Send message
  Future<void> sendMessage(String docId, Chatmodel chatmodel) async {
    final batch = FirebaseFirestore.instance.batch();
    try {
      CollectionReference chatCollection =
          _messagesCollection.doc(docId).collection('chat');
      batch.set(chatCollection.doc(), chatmodel.toJson());

      CollectionReference messageCollection = _messagesCollection;
      batch.update(messageCollection.doc(docId), {
        'lastMessage': chatmodel.message,
        'timeStamp': chatmodel.time,
      });

      final docRef = _messagesCollection.doc(docId);
      DocumentSnapshot snapshot = await docRef.get();
      if (snapshot.get('isGroup') == true) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      } else {
        if (snapshot.get('senderId') == chatmodel.id) {
          batch.update(docRef, {'recieverUnread': FieldValue.increment(01)});
        } else {
          batch.update(docRef, {'senderUnread': FieldValue.increment(01)});
        }
      }
      await batch.commit();
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}
