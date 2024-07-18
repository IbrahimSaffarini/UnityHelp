// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _textStyle = const TextStyle(fontSize: 23, color: Colors.white);
  final _borderStyle = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.white),
    borderRadius: BorderRadius.circular(15),
  );

  bool _isFormValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
    _firstNameController.addListener(_validateForm);
    _lastNameController.addListener(_validateForm);
    _phoneNumberController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _firstNameController.text.isNotEmpty &&
          _lastNameController.text.isNotEmpty &&
          _phoneNumberController.text.isNotEmpty;
    });
  }

  // A function to pass the content of the fields to the Auth method of Firebase
  Future signUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Authentication of the user
      if (passwordConfirmed()) {
        // Create User
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Add User Details
        await addUserDetails(
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
          _phoneNumberController.text.trim(),
          _emailController.text.trim(),
        );

        // Pop out of the registration page to go back to login page
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      // Error Handling when trying to register
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(e.message.toString()),
          );
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to add the information to the database
  Future addUserDetails(String Fn, String Ln, String Pn, String Email) async {
    User? currentUser = _auth.currentUser;
    await FirebaseFirestore.instance.collection('Users').doc(currentUser?.uid).set({
      'First Name': Fn,
      'Last Name': Ln,
      'Phone Number': Pn,
      'Email': Email,
      'Profile Pic': null,
    });
  }

  // A function to validate password & Confirm that passwords match
  bool passwordConfirmed() {
    if (_passwordController.text.trim() ==
        _confirmPasswordController.text.trim()) {
      return true;
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('Password does not Match'),
          );
        },
      );
      return false;
    }
  }

  // Dispose of the controllers while not using them
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _unfocusAndNavigate(VoidCallback navigationAction) {
    FocusScope.of(context).unfocus();
    Future.delayed(const Duration(milliseconds: 200), navigationAction);
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
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
          validator: validator,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          backgroundColor: const Color.fromARGB(255, 96, 88, 180),
          iconTheme: const IconThemeData(color: Colors.white, size: 30.0),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _unfocusAndNavigate(() {
                Navigator.pop(context);
              });
            },
          ),
          actions: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(child: CircularProgressIndicator(color: Colors.white)),
              )
            else
              IconButton(
                icon: const Icon(Icons.app_registration_rounded),
                onPressed: _isFormValid
                    ? () {
                        _unfocusAndNavigate(signUp);
                      }
                    : null,
                tooltip: 'Sign Up',
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/UnityHelp1.png',
                        height: MediaQuery.of(context).size.height * 0.19611,
                        width: MediaQuery.of(context).size.width,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Register below with your details',
                        style: GoogleFonts.notoSansKhudawadi(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildTextFormField(
                        controller: _firstNameController,
                        label: 'First Name',
                      ),
                      const SizedBox(height: 18),
                      _buildTextFormField(
                        controller: _lastNameController,
                        label: 'Last Name',
                      ),
                      const SizedBox(height: 18),
                      _buildTextFormField(
                        controller: _phoneNumberController,
                        label: 'Phone Number',
                      ),
                      const SizedBox(height: 18),
                      _buildTextFormField(
                        controller: _emailController,
                        label: 'Email',
                      ),
                      const SizedBox(height: 18),
                      _buildTextFormField(
                        controller: _passwordController,
                        label: 'Password',
                        obscureText: true,
                      ),
                      const SizedBox(height: 18),
                      _buildTextFormField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        obscureText: true,
                      ),
                    ],
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
