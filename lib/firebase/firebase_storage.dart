import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FireBaseFileStorageService{

  static final FireBaseFileStorageService _fileStorageService = FireBaseFileStorageService._internal();

  FireBaseFileStorageService._internal();

  factory FireBaseFileStorageService() => _fileStorageService;

  var storage = FirebaseStorage.instance;

  createSource(Reference ref, String child, File file) async {
    final String time = DateTime.now().toString();

    Reference reference = ref.child(child).child('$time.${file.path.split('.').last}');

    var snapshot = await reference.putFile(file);

    return reference;
  }

  deleteSource(String filePath) async {
    await storage.refFromURL(filePath).delete();
  }
}