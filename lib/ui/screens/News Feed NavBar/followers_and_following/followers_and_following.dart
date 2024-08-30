import 'package:check_in/ui/screens/%20Messages%20NavBar/other_profile/other_profile_view.dart';
import 'package:check_in/ui/screens/profile_screen.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FollowersAndFollowingScreen extends StatelessWidget {
  final bool showFollowers; // true for followers, false for following
  final String? otherUserId; // Optional parameter for other user's ID
  final String? origin;

  const FollowersAndFollowingScreen({
    Key? key,
    required this.showFollowers,
    this.otherUserId,
    this.origin,
  }) : super(key: key);

  Future<List<Map<String, String>>> _getUserDetails() async {
    // Use provided user ID or current user's ID if not provided
    String currentUserId =
        otherUserId ?? FirebaseAuth.instance.currentUser!.uid;
    String collection = showFollowers ? 'followers' : 'following';

    // Get the document containing the list of user IDs
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection(collection)
        .doc(currentUserId)
        .get();

    // Check if the document exists
    if (!doc.exists) {
      return [];
    }

    // Safely cast the document data to a Map<String, dynamic>
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    // Check if data is not null and contains the required key
    if (data != null) {
      List<dynamic> userIds =
          data[showFollowers ? 'followers' : 'following'] ?? [];

      // Fetch user details for all user IDs
      List<Map<String, String>> userDetails = [];
      for (String userId in userIds.cast<String>()) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('USER')
            .doc(userId)
            .get();
        if (userDoc.exists) {
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;
          if (userData != null) {
            String userName = userData['user name'] ?? 'Unknown User';
            String photoUrl = userData['photoUrl'] ?? '';
            userDetails.add({
              'user name': userName,
              'photoUrl': photoUrl,
              'uid': userId // Add UID here
            });
          }
        }
      }
      return userDetails;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: poppinsText(
            showFollowers ? 'Followers' : 'Following', 20, bold, appBlackColor),
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios)),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _getUserDetails(),
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

          List<Map<String, String>> userDetails = snapshot.data!;
          String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.only(
                      bottom: 16,
                      top: 16,
                      left: 30), // Add some padding around the heading
                  child: poppinsText(
                      '${userDetails.length} ${showFollowers ? 'Followers' : 'Following'}',
                      15,
                      bold,
                      Colors.green)),
              Expanded(
                child: ListView.builder(
                  itemCount: userDetails.length,
                  itemBuilder: (context, index) {
                    final user = userDetails[index];
                    bool isMyProfile = user['uid'] == currentUserUid;

                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 30.0), // 30 pixels padding from the left
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to the OtherProfileView screen with the selected user's UID
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtherProfileView(
                                uid: user['uid']!,
                                isMyProfile: isMyProfile, // Pass the parameter
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user['photoUrl'] != null &&
                                      user['photoUrl']!.isNotEmpty
                                  ? NetworkImage(user['photoUrl']!)
                                  : null,
                              child: user['photoUrl'] == null ||
                                      user['photoUrl']!.isEmpty
                                  ? Icon(Icons.person)
                                  : null,
                            ),
                            title: poppinsText(
                                user['user name'] ?? 'Unknown User',
                                11,
                                bold,
                                Colors.black)),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
