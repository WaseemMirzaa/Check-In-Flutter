import 'package:check_in/model/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/message_model.dart';

class MessageService {
  final db = FirebaseFirestore.instance;
  final batch = FirebaseFirestore.instance.batch();
  final CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('messages');

//............ Get Message
  Stream<List<Messagemodel>> getChatMessage(String myId) {
    return _messagesCollection
        .where(Filter.or(Filter('senderId', isEqualTo: myId),
            Filter('recieverId', isEqualTo: myId)))
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.map<Messagemodel>((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              String name = data['senderId'] == myId
                  ? data['recieverName']
                  : data['senderName'];
              String imagepath = data['senderId'] == myId
                  ? data['recieverImg']
                  : data['senderImg'];
              String unread = data['senderId'] == myId
                  ? data['senderUnread']
                  : data['recieverUnread'];

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
  Future<void> updateUnreadCount(String docId, String uId) async {
    final docRef = _messagesCollection.doc(docId);
    db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (snapshot.get('senderId') == uId) {
        docRef.update({'senderUnread': '0'});
      } else {
        docRef.update({'recieverUnread': '0'});
      }
    });
  }

//............ Send message
  Future<void> sendMessage(String docId, Chatmodel chatmodel) async {
    try {
      CollectionReference chatCollection =
          _messagesCollection.doc(docId).collection('chat');
      batch.set(chatCollection.doc(), chatmodel.toJson());

      CollectionReference messageCollection = _messagesCollection;
      batch.update(messageCollection.doc(docId),
          {'lastMessage': chatmodel.message, 'timeStamp': chatmodel.time});

      // final docRef = _messagesCollection.doc(docId);
      // DocumentSnapshot snapshot = await docRef.get();

      // if (snapshot.get('senderId') == chatmodel.id) {
      //   batch.update(docRef, {'senderUnread': FieldValue.increment(1)});
      // } else {
      //   batch.update(docRef, {'recieverUnread': FieldValue.increment(1)});
      // }

      await batch.commit();
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}
