import 'dart:io';
import 'package:disaster_relief_application/Utility/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordBottomSheet extends StatefulWidget {
  const ForgotPasswordBottomSheet({super.key});

  @override
  State<ForgotPasswordBottomSheet> createState() =>
      _ForgotPasswordBottomSheetState();
}

class _ForgotPasswordBottomSheetState extends State<ForgotPasswordBottomSheet> {
  double bottomSheetBottomSize = Platform.isIOS ? 30 : 10;
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isButtonEnabled = false;
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _emailError;
  final _textStyle = const TextStyle(fontSize: 23, color: Colors.white);
  final _borderStyle = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.white),
    borderRadius: BorderRadius.circular(15),
  );

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus(); // Hide the keyboard
      setState(() {
        _isLoading = true;
        _isButtonEnabled = false;
      });
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: _emailController.text.trim());
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });
        await Future.delayed(const Duration(seconds: 1));
        Navigator.of(context).pop();
      } on FirebaseAuthException catch (e) {
        print(e.message);
        setState(() {
          _isLoading = false;
          _isButtonEnabled = true;
          _emailError = e.message;
        });
        _formKey.currentState!.validate(); // Revalidate to show error messages
      }
    }
  }

  void _onEmailChanged() {
    setState(() {
      _emailError = null; // Clear previous error message
      _isButtonEnabled = _emailController.text.isNotEmpty;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (_emailError != null) {
      return _emailError;
    }
    return null;
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: TextFormField(
          controller: controller,
          style: _textStyle,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: _textStyle,
            border: _borderStyle,
            enabledBorder: _borderStyle,
            focusedBorder: _borderStyle.copyWith(
              borderSide: const BorderSide(color: Colors.white),
            ),
            errorStyle: const TextStyle(color: Colors.white),
          ),
          onChanged: (value) => _onEmailChanged(),
          validator: _validateEmail,
        ),
      );

  @override
  Widget build(BuildContext context) {
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
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Form(
              key: _formKey,
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
                          'Enter Email to Reset Password',
                          style: GoogleFonts.notoSansKhudawadi(
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextFormField(
                        controller: _emailController,
                        label: 'Email',
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: CustomButton.buildButton(
                          label: 'Reset Password',
                          icon: Icons.lock_open,
                          onPressed: _isButtonEnabled ? passwordReset : null,
                          isEnabled: _isButtonEnabled,
                          isLoading: _isLoading,
                          isSuccess: _isSuccess,
                        ),
                      ),
                      SizedBox(height: bottomSheetBottomSize),
                    ],
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
