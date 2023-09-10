import 'package:cloud_firestore/cloud_firestore.dart';

class CloudFirestoreHelper {
  CloudFirestoreHelper._();
  static final CloudFirestoreHelper cloudFirestoreHelper =
  CloudFirestoreHelper._();

  static final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  late CollectionReference authorkepperRef;
  void connectWithCollection() {
    authorkepperRef = firebaseFirestore.collection("author");
  }

  Future<void> insertrecord({required Map<String, dynamic> data}) async {
    connectWithCollection();

    await authorkepperRef.doc().set(data);
  }

  Stream<QuerySnapshot> selectrecord() {
    connectWithCollection();

    return authorkepperRef.snapshots();
  }

  Future<void> updateRecords(
      {required String id, required Map<String, dynamic> data}) async {
    connectWithCollection();

    await authorkepperRef.doc(id).update(data);
  }

  Future<void> deleterecord({required String id}) async {
    connectWithCollection();

    await authorkepperRef.doc(id).delete();
  }
}
