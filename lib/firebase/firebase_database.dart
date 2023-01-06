import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

class FirebaseRealTimeDatabase{

  static final FirebaseRealTimeDatabase _realTimeDatabase = FirebaseRealTimeDatabase._internal();

  FirebaseRealTimeDatabase._internal();

  factory FirebaseRealTimeDatabase() => _realTimeDatabase;

  /* [Variable Data Type]
  - String
  - boolean
  - int, double
  - Map
  - List */

  String? getNodeKey(DatabaseReference reference) => reference.key;

  static Map<String, dynamic> objectToJson(Object? object) {
    Map<String, dynamic> jsonData = jsonDecode(jsonEncode(object));
    return jsonData;
  }

  getNodeValue(DatabaseReference reference) => reference.get();

  Future<Object?> read(DatabaseReference reference) async{
    final snapshot = await reference.get();
    if(snapshot.exists){
      return snapshot.value;
    } else{
      return null;
    }
  }

  Future create({
    required DatabaseReference reference,
    required Map<String, dynamic> data,
  }) async {
    try{
      String newKey = reference.push().key.toString();

      data['uid'] = newKey;

      await reference.child(newKey).set(data);

      return true;
    } catch(error){
      print('Error Of Create Data: $error');
      return false;
    }
  }

  Future update({
    required DatabaseReference reference,
    required Map<String, dynamic> data,
  }) async {
    try{
      await reference.update(data);
      return true;
    } catch(error){
      print('Error Of Update Data: $error');
      return false;
    }
  }

  Future remove({
    required DatabaseReference reference,
    required Map<String, dynamic> data,
  }) async {
    try{
      await reference.remove();
      return true;
    } catch(error){
      print('Error Of Create Data: $error');
      return false;
    }
  }

  Future<List<DataSnapshot>> getValueOfNode(DatabaseReference reference) async{
    List<DataSnapshot> list = await reference.get().then((snapshot) {
      return snapshot.children.toList();
    }).catchError((error) {
      print('Failed Get Values: $error');
      return [];
    });
    return list;
  }

  Future<List<String>> getValueKeys(DatabaseReference reference) async{
    List<String> list = await getValueOfNode(reference).then((nodes) {
      return nodes.map((e) => e.key.toString()).toList();
    }).catchError((error) {
      print('Failed Get Keys Of Node');
      return [];
    });
    print('List is $list');
    return list;
  }

  Future<StreamSubscription> getListenData(DatabaseReference reference) async{
    return reference.onValue.listen((DatabaseEvent event) {
      final object = event.snapshot.value;
      update(
        reference: reference,
        data: object as Map<String, dynamic>,
      );
    });
  }
}