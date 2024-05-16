import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/model/NewsFeed%20Model/news_feed_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewsFeedService {
  final db = FirebaseFirestore.instance;
  final CollectionReference _newsFeedCollection =
      FirebaseFirestore.instance.collection(Collections.NEWSFEED);

  //............ Get newsfeed post
  Stream<List<NewsFeedModel>> getNewsFeed() {
    return _newsFeedCollection
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.map<NewsFeedModel>((doc) {
              return NewsFeedModel.fromJson(doc.data() as Map<String, dynamic>);
            }).toList());
  }

  /// Create news feed post
  Future<bool> createPost(NewsFeedModel newsFeedModel) async{
    try{
      await FirebaseFirestore.instance.collection(Collections.NEWSFEED).add(newsFeedModel.toJson());
        //  .add(newsFeedModel.toJson());
      return true;
    }catch (e){
      print(e.toString());
      return false;
    }
  }
}
