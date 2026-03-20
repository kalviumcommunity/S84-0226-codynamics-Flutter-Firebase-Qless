import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static final StorageService instance = StorageService._();
  StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// Uploads a file to Firebase Storage and returns its download URL.
  /// Returns null if upload fails, with error logged.
  Future<String?> uploadImage(File file, String folder) async {
    try {
      if (!await file.exists()) {
        throw Exception('File does not exist at: ${file.path}');
      }

      final String fileName = _uuid.v4();
      final Reference ref = _storage.ref().child('$folder/$fileName');
      
      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'uploaded_at': DateTime.now().toIso8601String()},
        ),
      );
      
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Firebase Storage Error: ${e.message}. Code: ${e.code}');
    } on SocketException catch (e) {
      throw Exception('Network Error: Unable to upload image. Please check your connection.');
    } on FileSystemException catch (e) {
      throw Exception('File Error: ${e.message}');
    } catch (e) {
      throw Exception('Upload failed: ${e.toString()}');
    }
  }
}
