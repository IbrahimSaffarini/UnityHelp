import 'package:disaster_relief_application/Authentication/forgot_password_bottom_sheet.dart';
import 'package:disaster_relief_application/Authentication/register_page.dart';
import 'package:disaster_relief_application/Utility/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key,});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _textStyle = const TextStyle(fontSize: 23, color: Colors.white);
  final _borderStyle = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.white),
    borderRadius: BorderRadius.circular(15),
  );

  String? _emailError;
  String? _passwordError;

  Future signIn() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        print("Sign in successful");
      } on FirebaseAuthException catch (e) {
        setState(() {
          if (e.code == 'user-not-found' || e.code == 'invalid-email') {
            _emailError = e.message;
          } else if (e.code == 'wrong-password') {
            _passwordError = e.message;
          } else {
            _emailError = e.message; // Default to email error if unspecified
          }
          _formKey.currentState!.validate();  // Revalidate to show error messages
        });
      }
    }
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (_passwordError != null) {
      return _passwordError;
    }
    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

  void _unfocusAndNavigate(VoidCallback navigationAction) {
    FocusScope.of(context).unfocus();
    Future.delayed(const Duration(milliseconds: 200), navigationAction);
  }

  void _showForgotPasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ForgotPasswordBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          automaticallyImplyLeading: false,
          iconTheme: const IconThemeData(color: Colors.white, size: 30),
          backgroundColor: const Color.fromARGB(255, 96, 88, 180),
          actions: [
            IconButton(
              icon: const Icon(Icons.lock_open),
              onPressed: _showForgotPasswordSheet,
            ),
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,  // Set the height to fill the screen
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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(
                    'assets/UnityHelp1.png',
                    height: MediaQuery.of(context).size.height * 0.24225,
                    width: MediaQuery.of(context).size.width,
                  ),
                  Column(
                    children: [
                      Text(
                        'Welcome Back!',
                        style: GoogleFonts.notoSansKhudawadi(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Login to your account',
                        style: GoogleFonts.rubik(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Email and Password text fields
                      _buildTextFormField(
                        controller: _emailController,
                        label: 'Email',
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 24),
                      _buildTextFormField(
                        controller: _passwordController,
                        label: 'Password',
                        obscureText: true,
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: CustomButton.buildButton(
                          label: 'Sign In',
                          icon: Icons.login,
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            signIn();
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('OR', style: TextStyle(color: Colors.white),),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Register now link
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: CustomButton.buildButton(
                          label: 'Register Now',
                          icon: Icons.app_registration,
                          onPressed: () {
                            _unfocusAndNavigate(() {
                              // Navigate directly to RegisterPage
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return const RegisterPage();
                                }),
                              );
                            });
                          },
                        ),
                      ),
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
