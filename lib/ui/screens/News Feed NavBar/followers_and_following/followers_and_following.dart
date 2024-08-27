import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FollowersAndFollowingScreen extends StatelessWidget {
  final bool showFollowers; // true for followers, false for following

  const FollowersAndFollowingScreen({Key? key, required this.showFollowers})
      : super(key: key);

  Future<List<String>> _getUserIds() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    String collection = showFollowers ? 'followers' : 'following';

    // Get the document containing the list of user IDs
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection(collection)
        .doc(currentUserId)
        .get();

    // Cast the document data to a Map<String, dynamic> and extract the user IDs
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<dynamic> userIds =
        data[showFollowers ? 'followers' : 'following'] ?? [];

    return userIds.cast<String>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showFollowers ? 'Followers' : 'Following'),
      ),
      body: FutureBuilder<List<String>>(
        future: _getUserIds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text(
                    'No ${showFollowers ? 'Followers' : 'Following'} found.'));
          }

          List<String> userIds = snapshot.data!;

          return ListView.builder(
            itemCount: userIds.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(userIds[index]),
              );
            },
          );
        },
      ),
    );
  }
}
