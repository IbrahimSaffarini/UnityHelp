import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;

class FirebaseProfileInformation {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<Map<String, dynamic>?> fetchCurrentUserProfile() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return null;
    }

    try {
      DocumentSnapshot userDoc = await _firestore.collection('Users').doc(currentUser.uid).get();

      if (!userDoc.exists) {
        return null;
      }

      Map<String, dynamic> userProfile = {
        'Email': userDoc['Email'] ?? 'No Email',
        'First Name': userDoc['First Name'] ?? 'No First Name',
        'Last Name': userDoc['Last Name'] ?? 'No Last Name',
        'Phone Number': userDoc['Phone Number'] ?? 'No Phone Number',
        'Profile Pic': (userDoc['Profile Pic'] == null || userDoc['Profile Pic'].isEmpty)
            ? 'https://t4.ftcdn.net/jpg/05/09/59/75/360_F_509597532_RKUuYsERhODmkxkZd82pSHnFtDAtgbzJ.jpg'
            : userDoc['Profile Pic'],
      };

      return userProfile;
    } catch (e) {
      return null;
    }
  }

  Future<File> compressAndResizeImage(File file) async {
    // Read the image from the file
    img.Image? image = img.decodeImage(file.readAsBytesSync());

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize the image to a maximum dimension of 800x800 (you can adjust this)
    img.Image resizedImage = img.copyResize(image, width: 800, height: 800);

    // Compress the image to a lower quality (you can adjust the quality)
    List<int> compressedImage = img.encodeJpg(resizedImage, quality: 80);

    // Save the compressed image to a new file
    File compressedFile = File(file.path.replaceAll('.jpg', '_compressed.jpg'));
    await compressedFile.writeAsBytes(compressedImage);

    return compressedFile;
  }

  Future<bool> updateUserProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? profilePicPath,
  }) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return false;
    }

    try {
      String? downloadUrl;

      if (profilePicPath != null && profilePicPath.isNotEmpty && !profilePicPath.startsWith('http')) {
        File imageFile = File(profilePicPath);

        // Compress and resize the image before uploading
        File compressedFile = await compressAndResizeImage(imageFile);

        String fileName = 'profile_pics/${currentUser.uid}.jpg';

        TaskSnapshot snapshot = await _storage.ref(fileName).putFile(compressedFile);
        downloadUrl = await snapshot.ref.getDownloadURL();
      }

      Map<String, dynamic> updateData = {
        'First Name': firstName,
        'Last Name': lastName,
        'Phone Number': phoneNumber,
        'Profile Pic': downloadUrl ?? profilePicPath ?? "", // Ensure the correct profile picture URL is used
      };

      await _firestore.collection('Users').doc(currentUser.uid).update(updateData);
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: currentPassword,
        );

        await currentUser.reauthenticateWithCredential(credential);
        await currentUser.updatePassword(newPassword);
        return true;
      } catch (e) {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> verifyCurrentPassword(String currentPassword) async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: currentPassword,
        );

        await currentUser.reauthenticateWithCredential(credential);
        return true;
      } catch (e) {
        return false;
      }
    } else {
      return false;
    }
  }
}
