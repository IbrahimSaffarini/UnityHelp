import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disaster_relief_application/Request/final_request_confirmation_page.dart';
import 'package:disaster_relief_application/Utility/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RequestConfirmationPage extends StatefulWidget {
  final Map<String, int> selectedSupplies;
  final bool isFromRequestInventory;
  final String? address;
  final double latitude;
  final double longitude;

  const RequestConfirmationPage({
    super.key,
    required this.selectedSupplies,
    required this.isFromRequestInventory,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<RequestConfirmationPage> createState() => _RequestConfirmationPageState();
}

class _RequestConfirmationPageState extends State<RequestConfirmationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool _isSuccess = false;
  double customPaddingSize = Platform.isIOS ? 6.5: 5.0;


  // Function to update quantities in Firestore based on selected supplies
  Future<void> updateSuppliesInFirestore() async {
    WriteBatch batch = _firestore.batch();

    for (final entry in widget.selectedSupplies.entries) {
      final String itemName = entry.key;
      final int selectedQuantity = entry.value;

      // Get the specific document for the item
      final DocumentReference<Map<String, dynamic>> docRef = _firestore
          .collection('Mobile Inventory Items')
          .doc(itemName);

      // Fetch the current item data
      final DocumentSnapshot<Map<String, dynamic>> docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final int currentQuantity = docSnapshot.data()?['Item Quantity'] ?? 0;

        // Calculate the updated quantity
        final int updatedQuantity = currentQuantity - selectedQuantity;

        // Update the document with the new quantity
        batch.update(docRef, {'Item Quantity': updatedQuantity});
      }
    }

    await batch.commit();
    print('Successfully updated supplies in batch.');
  }

  // Function to log the request details in Firestore
  Future<void> logRequestInFirestore() async {
    // Determine the collection type based on the boolean value
    final String requestType = widget.isFromRequestInventory
        ? 'Inventory Requests'
        : 'Custom Requests';

    // Fetch the current user's email address using Firebase Auth
    final User? user = FirebaseAuth.instance.currentUser;
    final String userEmail = user?.email ?? 'unknown_user';

    // Reference to the user's specific requests collection
    final CollectionReference userRequestsRef = _firestore
        .collection('Requests')
        .doc(requestType)
        .collection(userEmail)
        .doc('User Requests')
        .collection('Requests');

    // Determine the next request number
    final QuerySnapshot userRequestsSnapshot = await userRequestsRef.get();
    final int requestNumber = userRequestsSnapshot.docs.length + 1;
    final String requestDocName = 'Request_$requestNumber';

    // Create the request data
    final Map<String, dynamic> requestData = {
      'Address': widget.address,
      'Email Address': userEmail,
      'Latitude': widget.latitude,
      'Longitude': widget.longitude,
    };

    // Add the item data to the request
    int itemCounter = 1;
    widget.selectedSupplies.forEach((itemName, quantity) {
      requestData['Item $itemCounter Name'] = itemName;
      requestData['Item $itemCounter Quantity'] = quantity;
      itemCounter++;
    });

    // Save the request data to Firestore with a specific document name
    await userRequestsRef.doc(requestDocName).set(requestData);

    print('Request $requestNumber successfully logged with name $requestDocName.');
  }

  Future<void> _confirmRequest() async {
    setState(() {
      _isLoading = true;
    });

    final List<Future> operations = [];

    if (widget.isFromRequestInventory) {
      operations.add(updateSuppliesInFirestore());
    }
    operations.add(logRequestInFirestore());

    await Future.wait(operations);

    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const FinalRequestConfirmationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, int>> selectedEntries =
        widget.selectedSupplies.entries.toList();

    final int itemCount = selectedEntries.length;
    const double baseHeightFactor = 0.06;
    const double incrementFactor = 0.06;

    final double containerHeight = MediaQuery.of(context).size.height *
    (baseHeightFactor + (itemCount - 1) * incrementFactor).clamp(baseHeightFactor, 0.30);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.notoSansKhudawadi(color: Colors.white, fontSize: 24),
        centerTitle: true,
        title: const Text('Confirm Request'),
        backgroundColor: const Color.fromARGB(255, 96, 88, 180),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 96, 88, 180),
              Color.fromARGB(255, 130, 120, 185),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Center(
                    child: Image.asset(
                      'assets/CheckList.png',
                      height: MediaQuery.of(context).size.height * 0.23,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0, bottom: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Address Information',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSansKhudawadi(
                            fontSize: 21.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.address!,
                          style: GoogleFonts.rubik(fontSize: 18.0),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Chosen Items',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSansKhudawadi(
                            fontSize: 21.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          height: containerHeight,
                          child: SingleChildScrollView(
                            child: Column(
                              children: List<Widget>.generate(
                                selectedEntries.length,
                                    (index) => Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: customPaddingSize),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              selectedEntries[index].key,
                                              style: GoogleFonts.notoSansKhudawadi(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'x ${selectedEntries[index].value}',
                                              textAlign: TextAlign.right,
                                              style: GoogleFonts.rubik(
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (index != selectedEntries.length - 1)
                                      const Divider(
                                        color: Colors.black,
                                        thickness: 1.0,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: CustomButton.buildButton(
                      label: 'Confirm Request',
                      icon: Icons.check_circle_outline_outlined,
                      onPressed: _isLoading ? null : _confirmRequest,
                      isEnabled: !_isLoading,
                      isLoading: _isLoading,
                      isSuccess: _isSuccess,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
