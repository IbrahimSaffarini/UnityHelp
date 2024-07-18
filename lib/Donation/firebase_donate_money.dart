import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDonateMoney {
  final CollectionReference _donationsCollection = FirebaseFirestore.instance.collection('Donations');
  final int totalFunds = 150000;

  Future<void> initializeDatabase() async {
    List<String> categories = ['Animal Relief', 'Medical Assistance', 'Personalized Aid', 'Rebuild Homes', 'Supply Boost'];
    
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (String category in categories) {
        DocumentReference docRef = _donationsCollection.doc(category);
        batch.set(docRef, {'Money Raised': 0}, SetOptions(merge: true));
      }
      await batch.commit();
      print('Database initialized successfully.');
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

  Future<Map<String, dynamic>> fetchMoneyRaised() async {
    Map<String, dynamic> result = {'raised': [], 'percent': []};

    try {
      QuerySnapshot snapshot = await _donationsCollection.get();
      List<int> raised = [];
      List<double> percent = [];

      if (snapshot.docs.isEmpty) {
        await initializeDatabase();
        snapshot = await _donationsCollection.get();
      }

      snapshot.docs.forEach((doc) {
        int amount = doc['Money Raised'] ?? 0;
        raised.add(amount);
        percent.add(amount / totalFunds);
      });

      result['raised'] = raised;
      result['percent'] = percent;

      return result;
    } catch (e) {
      print('Error fetching data: $e');
      result['raised'] = List<int>.filled(5, 0);
      result['percent'] = List<double>.filled(5, 0.0);
      return result;
    }
  }
}
