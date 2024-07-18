import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disaster_relief_application/Donation/donation_confirmation.dart';
import 'package:disaster_relief_application/Stripe/payment_manager.dart';
import 'package:disaster_relief_application/Utility/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DonationBottomSheet extends StatefulWidget {
  final String title;

  const DonationBottomSheet({super.key, required this.title});

  @override
  State<DonationBottomSheet> createState() => _DonationBottomSheetState();
}

class _DonationBottomSheetState extends State<DonationBottomSheet> {
  double donationSheetBottomSize = Platform.isIOS ? 30 : 10;
  double? selectedAmount;
  final TextEditingController customAmountController = TextEditingController();
  bool isLoading = false;
  bool isSuccess = false;
  final _borderStyle = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.white),
    borderRadius: BorderRadius.circular(15),
  );

  @override
  void dispose() {
    customAmountController.dispose();
    super.dispose();
  }

  void onAmountSelected(double? amount) {
    FocusScope.of(context).unfocus(); // Unfocus the keyboard
    setState(() {
      selectedAmount = amount;
      customAmountController.clear();
    });
  }

  Future<void> handleDonate() async {
    FocusScope.of(context).unfocus(); // Unfocus the keyboard
    double? amount = selectedAmount ?? double.tryParse(customAmountController.text.replaceAll('\$', ''));
    if (amount != null && amount > 0) {
      setState(() {
        isLoading = true;
      });
      bool paymentSuccess = await PaymentManager.makePayment(amount.toInt(), "USD");
      if (paymentSuccess) {
        await updateDonationAmount(amount.toInt());
        setState(() {
          isLoading = false;
          isSuccess = true;
        });
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DonationConfirmation(
              amount: amount,
            ),
          ),
        );
      } else {
        // Handle payment error
        setState(() {
          isLoading = false;
        });
        print('Payment failed. Please try again.');
      }
    }
  }

  Future<void> updateDonationAmount(int amount) async {
    DocumentReference donationRef = FirebaseFirestore.instance.collection('Donations').doc(widget.title);
    await donationRef.update({
      'Money Raised': FieldValue.increment(amount),
    });
  }

  Widget buildDonationAmountButton(double amount) {
    return ElevatedButton(
      onPressed: () => onAmountSelected(amount),
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedAmount == amount
            ? const Color.fromARGB(255, 161, 155, 215)
            : Colors.white,
        foregroundColor: selectedAmount == amount
            ? Colors.white
            : const Color.fromARGB(255, 98, 89, 188),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 2.0,
      ),
      child: Text(
        '\$$amount',
        style: GoogleFonts.notoSansKhudawadi(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isButtonDisabled = (
      selectedAmount == null && 
      (customAmountController.text.isEmpty ||
        double.tryParse(customAmountController.text.replaceAll('\$', '')) == null
      )
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25.0),
            ),
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
            padding: EdgeInsets.only(
              left: 25.0,
              right: 25.0,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              children: [
                Container(
                  height: 5,
                  width: 50,
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        'Donating to ${widget.title}',
                        style: GoogleFonts.notoSansKhudawadi(
                          fontSize: 20, 
                          fontWeight: FontWeight.w700, 
                          color: Colors.white
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    buildDonationAmountButton(50.0),
                    const SizedBox(height: 10),
                    buildDonationAmountButton(100.0),
                    const SizedBox(height: 10),
                    buildDonationAmountButton(200.0),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('OR', style: GoogleFonts.rubik(color: Colors.white),),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      style: GoogleFonts.notoSansKhudawadi(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      controller: customAmountController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'Enter Price Manually',
                        hintStyle: GoogleFonts.notoSansKhudawadi(
                            color: Colors.white
                        ),
                        border: _borderStyle,
                        enabledBorder: _borderStyle,
                        focusedBorder: _borderStyle.copyWith(
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                      ),
                      onChanged: (value) {
                        if (!value.startsWith('\$')) {
                          customAmountController.value = TextEditingValue(
                            text: '\$$value',
                            selection: TextSelection.collapsed(offset: value.length + 1),
                          );
                        }
                        setState(() {
                          selectedAmount = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomButton.buildButton(
                      label: 'Donate Money',
                      icon: Icons.payment,
                      onPressed: handleDonate,
                      isEnabled: !isButtonDisabled,
                      isLoading: isLoading,
                      isSuccess: isSuccess,
                    ),
                    SizedBox(height: donationSheetBottomSize),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
