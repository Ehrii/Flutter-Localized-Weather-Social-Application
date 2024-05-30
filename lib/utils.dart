import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class StoreImage {
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<String?> getUserProfilePictureUrl(String email) async {
  try {
    final QuerySnapshot querySnapshot = await _firestore
        .collection('Users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final imageUrl = querySnapshot.docs.first.get('imageUrl');
      return imageUrl;
    } else {
      print('No user found with email: $email');
      return null;
    }
  } catch (e) {
    print('Failed to get user profile picture URL: $e');
    return null;
  }
}

  Future<String?> uploadImageToStorage(Uint8List file, String childName) async {
    try {
      firebase_storage.Reference ref = _storage.ref().child(childName);

      // Upload the file
      await ref.putData(file);

      // Get the download URL
      String downloadURL = await ref.getDownloadURL();

      // Return the download URL
      return downloadURL;
    } catch (e) {
      print('Failed to upload image to Firebase Storage: $e');
      return null;
    }
  }

  Future<void> addImageUrlToFirestore(String email, String imageUrl) async {
    try {
      // Reference to the user document in the "Users" collection
      final userRef = _firestore.collection('Users').doc(email);

      // Update the user document with the image URL
      await userRef.update({'imageUrl': imageUrl});
    } catch (e) {
      print('Failed to add image URL to Firestore: $e');
    }
  }
}



Future<Uint8List?> pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  final XFile? _file = await _imagePicker.pickImage(source: source);

  if (_file != null) {
    return await _file.readAsBytes();
  }
  print('No image selected');
  return null;
}
