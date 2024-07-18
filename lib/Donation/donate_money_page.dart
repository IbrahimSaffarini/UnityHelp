import 'dart:io';
import 'package:disaster_relief_application/Donation/donate_money_card.dart';
import 'package:disaster_relief_application/Donation/donation_bottom_sheet.dart';
import 'package:disaster_relief_application/Utility/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';

class DonateMoneyPage extends StatefulWidget {
  final Map<String, dynamic> donateMoneyData;

  const DonateMoneyPage({super.key, required this.donateMoneyData});

  @override
  _DonateMoneyPageState createState() => _DonateMoneyPageState();
}

class _DonateMoneyPageState extends State<DonateMoneyPage> {
  int _currentIndex = 0;
  final int totalFunds = 150000;
  List<double> percentages = [];
  List<int> moneyRaised = [];
  bool _autoPlay = true; // State variable for autoplay
  double carouselHeight = Platform.isIOS ? 0.72 : 0.74;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    setState(() {
      moneyRaised = widget.donateMoneyData['raised'];
      percentages = widget.donateMoneyData['percent'];
    });
  }

  void _handleBackNavigation() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> cards = [
      DonateMoneyCard(
        imagePath: 'assets/Repair.png',
        title: 'Rebuild Homes',
        moneyRaised: '\$${moneyRaised.isNotEmpty ? moneyRaised[3] : 0} of \$150000 raised (${percentages.isNotEmpty ? (percentages[3] * 100).toStringAsFixed(2) : 0}%)',
        percentage: percentages.isNotEmpty ? percentages[3] : 0.0,
        description: 'Help families in rebuilding their houses and restoring their lives by contributing to house repairs and reconstruction efforts.',
      ),
      DonateMoneyCard(
        imagePath: 'assets/Medical.png',
        title: 'Medical Assistance',
        moneyRaised: '\$${moneyRaised.isNotEmpty ? moneyRaised[1] : 0} of \$150000 raised (${percentages.isNotEmpty ? (percentages[1] * 100).toStringAsFixed(2) : 0}%)',
        percentage: percentages.isNotEmpty ? percentages[1] : 0.0,
        description: 'Provide essential medical aid to victims by covering their hospital bills and ensuring they receive the medical care they need.',
      ),
      DonateMoneyCard(
        imagePath: 'assets/Requests.png',
        title: 'Personalized Aid',
        moneyRaised: '\$${moneyRaised.isNotEmpty ? moneyRaised[2] : 0} of \$150000 raised (${percentages.isNotEmpty ? (percentages[2] * 100).toStringAsFixed(2) : 0}%)',
        percentage: percentages.isNotEmpty ? percentages[2] : 0.0,
        description: 'Contribute to a fund that allows us to fulfill victim\'s custom requests, providing them with personalized support.',
      ),
      DonateMoneyCard(
        imagePath: 'assets/Animal.png',
        title: 'Animal Relief',
        moneyRaised: '\$${moneyRaised.isNotEmpty ? moneyRaised[0] : 0} of \$150000 raised (${percentages.isNotEmpty ? (percentages[0] * 100).toStringAsFixed(2) : 0}%)',
        percentage: percentages.isNotEmpty ? percentages[0] : 0.0,
        description: 'Support the rescue of animals affected by disasters, ensuring they receive necessary treatment and shelter.',
      ),
      DonateMoneyCard(
        imagePath: 'assets/Inventory.png',
        title: 'Supply Boost',
        moneyRaised: '\$${moneyRaised.isNotEmpty ? moneyRaised[4] : 0} of \$150000 raised (${percentages.isNotEmpty ? (percentages[4] * 100).toStringAsFixed(2) : 0}%)',
        percentage: percentages.isNotEmpty ? percentages[4] : 0.0,
        description: 'Enhance our ability to respond swiftly by increasing the inventory of critical supplies needed for disaster relief operations.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: GoogleFonts.notoSansKhudawadi(
          color: Colors.white, // Color for the text
          fontSize: 24,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBackNavigation,
        ),
        centerTitle: true,
        title: const Text('Donate Money'),
        backgroundColor: const Color.fromARGB(255, 96, 88, 180)
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
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GFCarousel(
                  height: MediaQuery.of(context).size.height * carouselHeight,
                  items: cards,
                  autoPlay: _autoPlay,
                  viewportFraction: 1.0,
                  aspectRatio: 1.0,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(cards.length, (index) {
                    return Container(
                      width: 12.0,
                      height: 12.0,
                      margin: const EdgeInsets.symmetric(horizontal: 3.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? const Color.fromARGB(255, 96, 88, 180)
                            : Colors.white,
                        border: _currentIndex == index
                            ? Border.all(color: Colors.white, width: 2.0)
                            : null,
                      ),
                    );
                  }),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: CustomButton.buildButton(
                    label: 'Donate Money',
                    icon: Icons.payment,
                    onPressed: () {
                      setState(() {
                        _autoPlay = false; // Stop autoplay
                      });
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          final DonateMoneyCard currentCard =
                              cards[_currentIndex] as DonateMoneyCard;
                          return DonationBottomSheet(title: currentCard.title);
                        },
                      ).then((_) {
                        setState(() {
                          _autoPlay =
                              true; // Resume autoplay when bottom sheet is dismissed
                        });
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
