import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseStore{

  static final FirebaseStore _firebaseFireStore = FirebaseStore._internal();

  FirebaseStore._internal();

  factory FirebaseStore() => _firebaseFireStore;

  String getUid(CollectionReference ref) => ref.doc().id;

  Future create(CollectionReference ref, dynamic data) async {
    data.uid = ref.doc().id;
    await ref.doc(data.uid).set(data.toJson());
  }

  Future createWithUid(CollectionReference ref, String uid, dynamic data) async {
    data.uid = uid;
    await ref.doc(data.uid).set(data.toJson());
  }

  Future<DocumentSnapshot> read(CollectionReference ref, String uid) async {
    // ignore: unnecessary_null_comparison
    assert(uid != null);
    return await ref.doc(uid).get();
  }

  update(CollectionReference ref, dynamic data) async {
    assert(data.uid != null);
    await ref.doc(data.uid).set(data.toJson());
  }

  delete(CollectionReference ref, dynamic data) async {
    assert(data.uid != null);
    await ref.doc(data.uid).delete();
  }

}