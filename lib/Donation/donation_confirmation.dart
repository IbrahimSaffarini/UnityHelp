import 'package:disaster_relief_application/Authentication/main_page.dart';
import 'package:disaster_relief_application/Donation/donate_money_page.dart';
import 'package:disaster_relief_application/Donation/firebase_donate_money.dart';
import 'package:disaster_relief_application/Utility/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DonationConfirmation extends StatefulWidget {
  final double amount;

  const DonationConfirmation({super.key, required this.amount});

  @override
  _DonationConfirmationState createState() => _DonationConfirmationState();
}

class _DonationConfirmationState extends State<DonationConfirmation> {
  Future<Map<String, dynamic>>? _donateMoneyDataFuture;
  final FirebaseDonateMoney _firebaseDonateMoney = FirebaseDonateMoney();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDonateMoneyData();
  }

  void _loadDonateMoneyData() {
    setState(() {
      _donateMoneyDataFuture = _firebaseDonateMoney.fetchMoneyRaised();
    });
  }

  void _navigateToDonateMoneyPage(BuildContext context, Map<String, dynamic> donateMoneyData) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DonateMoneyPage(donateMoneyData: donateMoneyData)),
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
                const SizedBox(height: 15.0),
                Text(
                  "Thank you! The Generous \$${widget.amount.toStringAsFixed(2)} Donation was Received Successfully!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansKhudawadi(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                FutureBuilder<Map<String, dynamic>>(
                  future: _donateMoneyDataFuture,
                  builder: (context, snapshot) {
                    return CustomButton.buildButton(
                      label: 'Donate More Money',
                      icon: Icons.payment,
                      onPressed: snapshot.hasData ? () => 
                        _navigateToDonateMoneyPage(context, snapshot.data!) 
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
