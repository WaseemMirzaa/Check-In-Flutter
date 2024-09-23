import 'package:check_in/ui/screens/%20Messages%20NavBar/other_profile/other_profile_view.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/common.dart';
import 'package:check_in/utils/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FollowersAndFollowingScreen extends StatefulWidget {
  final bool showFollowers; // true for followers, false for following
  final String? otherUserId; // Optional parameter for other user's ID
  final String count;

  const FollowersAndFollowingScreen({
    Key? key,
    required this.showFollowers,
    this.otherUserId,
    required this.count,
  }) : super(key: key);

  @override
  _FollowersAndFollowingScreenState createState() =>
      _FollowersAndFollowingScreenState();
}

class _FollowersAndFollowingScreenState
    extends State<FollowersAndFollowingScreen> {
  List<Map<String, String>> userDetails = [];
  bool isLoading = false;
  bool hasMoreData = true;
  DocumentSnapshot? lastDocument; // To keep track of the last document
  final ScrollController _scrollController = ScrollController();
  int FETCH_LIMIT = 30;

  @override
  void initState() {
    super.initState();
    _getUserDetails(); // Fetch initial data

    // Add scroll listener to load more data when scrolled to bottom
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          hasMoreData && !isLoading) {
        _getUserDetails();
      }
    });
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getUserDetails() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    String currentUserId =
        widget.otherUserId ?? FirebaseAuth.instance.currentUser!.uid;
    String collection = widget.showFollowers ? 'followers' : 'following';

    // Access the appropriate subcollection
    CollectionReference userSubCollection = FirebaseFirestore.instance
        .collection(collection)
        .doc(currentUserId)
        .collection(collection);

    // Add pagination: limit to FETCH_LIMIT documents at a time
    Query query = userSubCollection.limit(FETCH_LIMIT);
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!); // Continue after last fetched doc
    }

    QuerySnapshot querySnapshot = await query.get();

    if (querySnapshot.docs.isEmpty || querySnapshot.docs.length < FETCH_LIMIT) {
      // If no more data or fewer than FETCH_LIMIT docs are returned, stop loading more
      setState(() {
        hasMoreData = false; // No more data to load
      });
    }

    if (querySnapshot.docs.isNotEmpty) {
      lastDocument = querySnapshot.docs.last; // Save last document for pagination

      // Fetch all user IDs in one call
      List<String> userIds = querySnapshot.docs.map((doc) => doc.id).toList();

      // Fetch all user details in one query using Firestore 'in' query
      QuerySnapshot userDocsSnapshot = await FirebaseFirestore.instance
          .collection('USER')
          .where(FieldPath.documentId, whereIn: userIds)
          .get();

      // Add user details to the list
      userDetails.addAll(
        userDocsSnapshot.docs.map((userDoc) {
          Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
          return {
            'user name': (userData?['user name'] ?? 'Unknown User').toString(),
            'photoUrl': (userData?['photoUrl'] ?? '').toString(),
            'uid': userDoc.id.toString(),
          };
        }).toList(),
      );

    }

    setState(() {
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: poppinsText(
            widget.showFollowers ? 'Followers' : 'Following',
            20,
            bold,
            appBlackColor),
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                bottom: 16, top: 16, left: 30), // Add some padding around heading
            child: poppinsText(
              '${widget.count} ${widget.showFollowers ? 'Followers' : 'Following'}',
              15,
              bold,
              Colors.green,
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Attach scroll controller
              itemCount: userDetails.length + 1, // Add 1 for loading indicator
              itemBuilder: (context, index) {
                if (index == userDetails.length) {
                  // Show loading indicator at the end
                  return hasMoreData
                      ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                      : SizedBox(); // No more data to load
                }

                final user = userDetails[index];
                bool isMyProfile =
                    user['uid'] == FirebaseAuth.instance.currentUser!.uid;

                return Padding(
                  padding: const EdgeInsets.only(left: 30.0), // 30 pixels padding from the left
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
                          Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
