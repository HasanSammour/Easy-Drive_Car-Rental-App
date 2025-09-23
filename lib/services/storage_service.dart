import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage(String userId, XFile imageFile) async {
    try {
      final Reference ref = _storage.ref().child('profile_images/$userId');
      final UploadTask uploadTask = ref.putData(await imageFile.readAsBytes());
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String> uploadCarImage(String carId, XFile imageFile) async {
    try {
      final Reference ref = _storage.ref().child('car_images/$carId/${DateTime.now().millisecondsSinceEpoch}');
      final UploadTask uploadTask = ref.putData(await imageFile.readAsBytes());
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload car image: $e');
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }
}