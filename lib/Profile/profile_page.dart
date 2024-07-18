import 'dart:io';
import 'package:disaster_relief_application/Medical_Information/firebase_medical_information.dart';
import 'package:disaster_relief_application/Medical_Information/medical_information.dart';
import 'package:disaster_relief_application/Profile/edit_profile_information.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyProfile extends StatefulWidget {
  final Map<String, dynamic> userData;

  const MyProfile({super.key, required this.userData});

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;

  final _textStyle = const TextStyle(fontSize: 23, color: Colors.white);
  final _borderStyle = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.white),
    borderRadius: BorderRadius.circular(15),
  );

  String? _imagePath; // State variable to hold the path of the selected image

  Future<Map<String, dynamic>?>? _medicalDataFuture;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.userData['First Name']);
    _lastNameController = TextEditingController(text: widget.userData['Last Name']);
    _emailController = TextEditingController(text: widget.userData['Email']);
    _phoneNumberController = TextEditingController(text: widget.userData['Phone Number']);
    _imagePath = widget.userData['Profile Pic'];
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadMedicalData();
  }

  void _loadMedicalData() {
    setState(() {
      _medicalDataFuture = FirebaseMedicalInformation().fetchMedicalInfo();
    });
  }

  void _navigateToMedicalInfoPage(BuildContext context, Map<String, dynamic>? medicalData) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MedicalInformationPage(medicalData: medicalData ?? {})),
    ).then((_) => _loadMedicalData()); // Reload medical data when coming back to HomePage
  }
  
  ImageProvider<Object> _getImage() {
    if (_imagePath != null && _imagePath!.isNotEmpty) {
      if (_imagePath!.startsWith('http')) {
        return NetworkImage(_imagePath!);
      } else {
        return FileImage(File(_imagePath!));
      }
    } else {
      return const NetworkImage(
          'https://t4.ftcdn.net/jpg/05/09/59/75/360_F_509597532_RKUuYsERhODmkxkZd82pSHnFtDAtgbzJ.jpg');
    }
  }

  Future<void> _navigateToEditProfile() async {
    final updatedUserData = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfileInformation(userData: widget.userData),
      ),
    );

    if (updatedUserData != null) {
      setState(() {
        widget.userData.addAll(updatedUserData);
        _firstNameController.text = updatedUserData['First Name'];
        _lastNameController.text = updatedUserData['Last Name'];
        _emailController.text = updatedUserData['Email'];
        _phoneNumberController.text = updatedUserData['Phone Number'];
        _imagePath = updatedUserData['Profile Pic'];
      });
    }
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
  }) =>
      TextFormField(
        controller: controller,
        readOnly: true,
        style: _textStyle,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: _textStyle,
          border: _borderStyle,
          enabledBorder: _borderStyle,
          focusedBorder: _borderStyle.copyWith(
            borderSide: const BorderSide(color: Colors.white),
          ),
        ),
      );

  Widget _buildButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: const Color.fromARGB(255, 98, 89, 188)),
      label: Text(
        label,
        style: const TextStyle(fontSize: 25, color: Color.fromARGB(255, 98, 89, 188)),
      ),
      onPressed: onPressed ?? () {}, // Provide a dummy function to keep the button enabled
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 23),
        minimumSize: const Size(double.infinity, 60),
        textStyle: _textStyle,
        elevation: 2.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: GoogleFonts.notoSansKhudawadi(color: Colors.white, fontSize: 24),
        centerTitle: true,
        title: const Text('My Profile'),
        backgroundColor: const Color.fromARGB(255, 96, 88, 180),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditProfile,
          ),
        ],
      ),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0, left: 16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: MediaQuery.of(context).size.height * 0.15,
                        backgroundImage: _getImage(),
                      ),
                      const SizedBox(height: 24),
                      _buildTextFormField(
                        controller: _firstNameController,
                        label: 'First Name',
                      ),
                      const SizedBox(height: 24),
                      _buildTextFormField(
                        controller: _lastNameController,
                        label: 'Last Name',
                      ),
                      const SizedBox(height: 24),
                      _buildTextFormField(
                        controller: _emailController,
                        label: 'Email',
                      ),
                      const SizedBox(height: 24),
                      _buildTextFormField(
                        controller: _phoneNumberController,
                        label: 'Phone Number',
                      ),
                      const SizedBox(height: 24),
                      FutureBuilder<Map<String, dynamic>?>(
                        future: _medicalDataFuture,
                        builder: (context, snapshot) {
                          return _buildButton(
                            label: 'Medical Information',
                            icon: Icons.medical_information,
                            onPressed: snapshot.connectionState == ConnectionState.done
                                ? () => _navigateToMedicalInfoPage(context, snapshot.data)
                                : null, // Disable button until data is loaded
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
