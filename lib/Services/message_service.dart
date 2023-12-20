import 'package:check_in/model/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/message_model.dart';

class MessageService {
  final CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('messages');
//............ Get Message
  Stream<List<Messagemodel>>? getChatMessage(String myId) {
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

              return Messagemodel.fromJson(
                  doc.data() as Map<String, dynamic>, name, imagepath);
            }).toList());
  }

//............ Get conversations
  Stream<List<Chatmodel>> getConversation(String uId) {
    return _messagesCollection
        .doc(uId)
        .collection('chat')
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map<Chatmodel>((doc) => Chatmodel.fromJson(doc.data()))
            .toList());
  }

//............ Send message
  Future<void> sendMessage(String docId, Chatmodel chatmodel) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      CollectionReference chatCollection =
          _messagesCollection.doc(docId).collection('chat');
      batch.set(chatCollection.doc(), chatmodel.toJson());

      CollectionReference messageCollection = _messagesCollection;
      batch.update(messageCollection.doc(docId),
          {'lastMessage': chatmodel.message, 'timeStamp': chatmodel.time});
      await batch.commit();
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}
