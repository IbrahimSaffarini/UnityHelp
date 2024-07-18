import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseMedicalInformation {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserData({
    required String? selectedAge,
    required String? selectedChestPain,
    required String? selectedExerciseAngina,
    required String? selectedHypertension,
    required String? selectedHeartDisease,
    required String? selectedSmokingStatus,
    required String classificationResult,
  }) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore.collection('medicalInfo').doc(currentUser.email).set({
        'Age': selectedAge?.split(': ').last.split(' ').first,
        'Chest Pain Type': selectedChestPain?.split(': ').last,
        'Exercise Angina': selectedExerciseAngina?.split(': ').last,
        'Hypertension': selectedHypertension?.split(': ').last,
        'Heart Disease': selectedHeartDisease?.split(': ').last,
        'Smoking Status': selectedSmokingStatus?.split(': ').last,
        'Classification': classificationResult,
      });
    }
  }

  Future<Map<String, dynamic>?> fetchMedicalInfo() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userData = await _firestore.collection('medicalInfo').doc(currentUser.email).get();
      if (userData.exists) {
        return userData.data() as Map<String, dynamic>?;
      }
    }
    return null;
  }
}
