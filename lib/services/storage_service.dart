import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static final StorageService instance = StorageService._();
  StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// Uploads a file to Firebase Storage and returns its download URL.
  Future<String?> uploadImage(File file, String folder) async {
    try {
      final String fileName = _uuid.v4();
      final Reference ref = _storage.ref().child('$folder/$fileName');
      
      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }
}
