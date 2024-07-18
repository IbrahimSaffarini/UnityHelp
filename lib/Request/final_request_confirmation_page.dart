import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:disaster_relief_application/Authentication/main_page.dart';
import 'package:disaster_relief_application/Request/request_from_inventory_page.dart';
import 'package:disaster_relief_application/Request/firebase_request_from_inventory.dart';
import 'package:disaster_relief_application/Utility/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FinalRequestConfirmationPage extends StatefulWidget {
  const FinalRequestConfirmationPage({super.key});

  @override
  State<FinalRequestConfirmationPage> createState() => _FinalRequestConfirmationPageState();
}

class _FinalRequestConfirmationPageState extends State<FinalRequestConfirmationPage> {
  Future<List<DocumentSnapshot>>? _inventoryDataFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadInventoryData();
  }

  void _loadInventoryData() {
    setState(() {
      _inventoryDataFuture = FirebaseRequestFromInventory().fetchInventoryItems();
    });
  }

  void _navigateToRequestFromInventoryPage(BuildContext context, List<DocumentSnapshot> inventoryItems) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RequestFromInventoryPage(inventoryItems: inventoryItems)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
          padding: const EdgeInsets.all(16.0), // Ensures consistent padding around all child widgets
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/Confirm.png',
                  height: MediaQuery.of(context).size.height * 0.30,
                ),
                const SizedBox(height: 20.0),
                Text(
                  "Thank you the Request was Received Successfully!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansKhudawadi(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                FutureBuilder<List<DocumentSnapshot>>(
                  future: _inventoryDataFuture,
                  builder: (context, snapshot) {
                    return CustomButton.buildButton(
                      label: 'Make Another Request',
                      icon: CommunityMaterialIcons.hand_heart,
                      onPressed: snapshot.hasData ? () => 
                        _navigateToRequestFromInventoryPage(context, snapshot.data!) 
                        : (){}, // Dummy function to keep the button visibly enabled
                      isEnabled: true,
                    );
                  },
                ),
                const SizedBox(height: 12),
                CustomButton.buildButton(
                  label: 'Go to the Home Page',
                  icon: Icons.home,
                  onPressed: () {
                    // Navigates to the HomePage without clearing navigation stack
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const MainPage()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  isEnabled: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
