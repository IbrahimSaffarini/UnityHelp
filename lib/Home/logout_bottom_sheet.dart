import 'dart:io';
import 'package:disaster_relief_application/Utility/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogOutBottomSheet extends StatefulWidget {
  const LogOutBottomSheet({super.key});

  @override
  State<LogOutBottomSheet> createState() =>
      _LogOutBottomSheetState();
}

class _LogOutBottomSheetState extends State<LogOutBottomSheet> {
  double bottomSheetBottomSize = Platform.isIOS ? 30 : 10;

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                      'Do you want to Log Out ?',
                      style: GoogleFonts.notoSansKhudawadi(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: CustomButton.buildButton(
                      label: 'Log Out',
                      icon: Icons.logout,
                      onPressed: _signOut,
                    ),
                  ),
                  SizedBox(height: bottomSheetBottomSize),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
