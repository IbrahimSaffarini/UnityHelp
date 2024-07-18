import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';

class DonateMoneyCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String moneyRaised;
  final double percentage;
  final String description;

  const DonateMoneyCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.moneyRaised,
    required this.percentage,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    // Split the moneyRaised string to get the raised and goal amounts
    final parts = moneyRaised.split(' ');
    final raisedAmount = parts[0];
    final goalAmount = parts[2];

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
            child: Image.asset(
              imagePath,
              height: MediaQuery.of(context).size.height * 0.43,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSansKhudawadi(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: raisedAmount,
                            style: GoogleFonts.notoSansKhudawadi(
                              fontWeight: FontWeight.w700,
                              color: const Color.fromARGB(255, 96, 88, 180), // Customizable color
                              fontSize: 20, // Bigger font size for raised amount
                            ),
                          ),
                          TextSpan(
                            text: ' of ',
                            style: GoogleFonts.rubik(
                              color: const Color.fromARGB(255, 104, 104, 104), // Match the color of "funded"
                              fontSize: 17,
                            ),
                          ),
                          TextSpan(
                            text: goalAmount,
                            style: GoogleFonts.notoSansKhudawadi(
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontSize: 17,
                            ),
                          ),
                          TextSpan(
                            text: ' funded',
                            style: GoogleFonts.rubik(
                              color: const Color.fromARGB(255, 104, 104, 104),
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${(percentage * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.rubik(
                        color: const Color.fromARGB(255, 104, 104, 104),
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                GFProgressBar(
                  percentage: percentage,
                  lineHeight: 25,
                  alignment: MainAxisAlignment.spaceBetween,
                  backgroundColor: Colors.black26,
                  progressBarColor: const Color.fromARGB(255, 96, 88, 180),
                ),
                const SizedBox(height: 10.0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Description:',
                    style: GoogleFonts.notoSansKhudawadi(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 5.0),
                Text(
                  description,
                  textAlign: TextAlign.justify,
                  style: GoogleFonts.rubik(fontSize: 17.0, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}