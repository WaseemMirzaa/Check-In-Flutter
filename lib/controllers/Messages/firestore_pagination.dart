import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreQueryBuilder<T> {
  late Query query;

  FirestoreQueryBuilder(Query initialQuery) {
    query = initialQuery;
  }

  FirestoreQueryBuilder<T> where(String field, {dynamic isEqualTo}) {
    // Modify this as per your needs
    query = query.where(field, isEqualTo: isEqualTo);
    return this;
  }

  FirestoreQueryBuilder<T> orderBy(String field, {bool descending = false}) {
    query = query.orderBy(field, descending: descending);
    return this;
  }

  Query<T> buildQuery() {
    return query as Query<T>;
  }
}

class FirestoreListView<T> extends StatelessWidget {
  final Query<T> query;
  final Widget Function(BuildContext context, DocumentSnapshot<T> document)
      itemBuilder;

  const FirestoreListView({
    super.key,
    required this.query,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<T>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator(); // Replace with your loading widget
        }

        final documents = snapshot.data!.docs;

        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) =>
              itemBuilder(context, documents[index]),
        );
      },
    );
  }
}
