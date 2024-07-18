import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:disaster_relief_application/Donation/donate_money_page.dart';
import 'package:disaster_relief_application/Donation/firebase_donate_money.dart';
import 'package:disaster_relief_application/Profile/firebase_profile_information.dart';
import 'package:disaster_relief_application/Profile/profile_page.dart';
import 'package:disaster_relief_application/Request/request_from_inventory_page.dart';
import 'package:disaster_relief_application/Request/firebase_request_from_inventory.dart';
import 'package:disaster_relief_application/Home/logout_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  Future<Map<String, dynamic>?>? _profileDataFuture;
  Future<List<DocumentSnapshot>>? _inventoryDataFuture;
  Future<Map<String, dynamic>>? _donateMoneyDataFuture;
  final FirebaseRequestFromInventory _firebaseRequest = FirebaseRequestFromInventory();
  final FirebaseDonateMoney _firebaseDonateMoney = FirebaseDonateMoney();
  double titleFontSize = Platform.isIOS ? 26 : 25;
  double subTitleFontSize = Platform.isIOS ? 19 : 18;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProfileData();
    _loadInventoryData();
    _loadDonateMoneyData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfileData();
    _loadInventoryData();
    _loadDonateMoneyData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadProfileData();
      _loadInventoryData();
      _loadDonateMoneyData();
    }
  }

  void _loadProfileData() {
    setState(() {
      _profileDataFuture = FirebaseProfileInformation().fetchCurrentUserProfile();
    });
  }

  void _loadInventoryData() async {
    final inventoryData = await _firebaseRequest.fetchInventoryItems();
    if (inventoryData.isEmpty) {
      await _firebaseRequest.initializeInventory();
      setState(() {
        _inventoryDataFuture = _firebaseRequest.fetchInventoryItems();
      });
    } else {
      setState(() {
        _inventoryDataFuture = Future.value(inventoryData);
      });
    }
  }

  void _loadDonateMoneyData() {
    setState(() {
      _donateMoneyDataFuture = _firebaseDonateMoney.fetchMoneyRaised();
    });
  }

  void _navigateToProfilePage(BuildContext context, Map<String, dynamic> userData) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyProfile(userData: userData)),
    ).then((_) {
      _loadProfileData(); // Reload data when coming back to HomePage
      _loadInventoryData(); // Also reload inventory data
      _loadDonateMoneyData(); // Also reload donation data
    });
  }

  void _navigateToRequestFromInventoryPage(BuildContext context, List<DocumentSnapshot> inventoryItems) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RequestFromInventoryPage(inventoryItems: inventoryItems)),
    ).then((_) {
      _loadProfileData(); // Also reload profile data
      _loadInventoryData(); // Reload data when coming back to HomePage
      _loadDonateMoneyData(); // Also reload donation data
    });
  }

  void _navigateToDonateMoneyPage(BuildContext context, Map<String, dynamic> donateMoneyData) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DonateMoneyPage(donateMoneyData: donateMoneyData)),
    ).then((_) {
      _loadProfileData(); // Also reload profile data
      _loadInventoryData(); // Reload data when coming back to HomePage
      _loadDonateMoneyData(); // Also reload donation data
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 96, 88, 180),
        iconTheme: const IconThemeData(color: Colors.white, size: 30.0),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context){
                return const LogOutBottomSheet();
              }
            );
          },
        ),
        actions: [
          FutureBuilder<Map<String, dynamic>?>(
            future: _profileDataFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () => _navigateToProfilePage(context, snapshot.data!),
                );
              } else {
                return const IconButton(
                  icon: Icon(Icons.person, color: Colors.white),
                  onPressed: null, // Disable tap until data is loaded
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height, // Set the height to fill the screen
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
        child: Column(
          children: [
            Image.asset(
              'assets/UnityHelpNT.png',
              height: MediaQuery.of(context).size.height * 0.1154,
              width: MediaQuery.of(context).size.width,
            ),
            Text(
              'Welcome To Unity Help!',
              style: GoogleFonts.notoSansKhudawadi(
                color: Colors.white,
                fontSize: titleFontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Empowering Through Connections',
              style: GoogleFonts.rubik(
                color: Colors.white,
                fontSize: subTitleFontSize,
              ),
            ),
            const SizedBox(height: 15),
            // First Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FutureBuilder<List<DocumentSnapshot>>(
                  future: _inventoryDataFuture,
                  builder: (context, snapshot) {
                    return _buildActionBox(
                      context,
                      icon: CommunityMaterialIcons.hand_heart,
                      label: 'Request Supplies',
                      onTap: snapshot.hasData ? () => 
                      _navigateToRequestFromInventoryPage(context, snapshot.data!) 
                      : () {}, // Dummy function
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Second Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FutureBuilder<Map<String, dynamic>>(
                  future: _donateMoneyDataFuture,
                  builder: (context, snapshot) {
                    return _buildActionBox(
                      context,
                      icon: Icons.payment,
                      label: 'Donate Money',
                      onTap: snapshot.hasData ? () =>
                      _navigateToDonateMoneyPage(context, snapshot.data!) 
                      : () {}, // Dummy function
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBox(
    BuildContext context, {
    required IconData icon,
    required String label,
    Widget? destination,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ??
          () {
            if (destination != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => destination),
              );
            }
          },
      child: Container(
        width: MediaQuery.of(context).size.height * 0.3461,
        height: MediaQuery.of(context).size.height * 0.323,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 145, 139, 208).withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35), // Shadow color
              spreadRadius: 2, // Spread radius
              blurRadius: 5, // Blur radius
              offset: const Offset(0, 3), // Offset
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansKhudawadi(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
