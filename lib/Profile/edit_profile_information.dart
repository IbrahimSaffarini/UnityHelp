import 'dart:io';
import 'package:disaster_relief_application/Profile/edit_image_bottom_sheet.dart';
import 'package:disaster_relief_application/Profile/firebase_profile_information.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileInformation extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileInformation({super.key, required this.userData});

  @override
  _EditProfileInformationState createState() => _EditProfileInformationState();
}

class _EditProfileInformationState extends State<EditProfileInformation> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;

  final _formKey = GlobalKey<FormState>();
  final _textStyle = const TextStyle(fontSize: 23, color: Colors.white);
  final _borderStyle = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.white),
    borderRadius: BorderRadius.circular(15),
  );

  String? _imagePath;
  String? _originalImagePath;
  bool _hasChanges = false;
  bool _isLoading = false;
  bool _isCurrentPasswordValid = true;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.userData['First Name']);
    _lastNameController = TextEditingController(text: widget.userData['Last Name']);
    _emailController = TextEditingController(text: widget.userData['Email']);
    _phoneNumberController = TextEditingController(text: widget.userData['Phone Number']);
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _originalImagePath = widget.userData['Profile Pic'];
    _imagePath = _originalImagePath;

    _firstNameController.addListener(_checkForChanges);
    _lastNameController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
    _phoneNumberController.addListener(_checkForChanges);
    _currentPasswordController.addListener(_checkForChanges);
    _newPasswordController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    bool hasChanges = _firstNameController.text != widget.userData['First Name'] ||
        _lastNameController.text != widget.userData['Last Name'] ||
        _emailController.text != widget.userData['Email'] ||
        _phoneNumberController.text != widget.userData['Phone Number'] ||
        (_imagePath != _originalImagePath) ||
        _currentPasswordController.text.isNotEmpty ||
        _newPasswordController.text.isNotEmpty;

    setState(() {
      _hasChanges = hasChanges;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
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
      );

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final ImageSource? source = await showEditImageBottomSheet(context, _removeImage);

    if (source != null) {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _imagePath = image.path;
          _checkForChanges();
        });
      }
    }
  }

  void _removeImage() {
    setState(() {
      _imagePath = "";
      _checkForChanges();
    });
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

  Future<void> _confirmChanges() async {
    setState(() {
      _isLoading = true;
    });

    FirebaseProfileInformation firebaseInfoProfile = FirebaseProfileInformation();

    bool profileUpdateSuccess = await firebaseInfoProfile.updateUserProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phoneNumber: _phoneNumberController.text,
      profilePicPath: _imagePath == "" ? null : _imagePath,
    );

    if (profileUpdateSuccess) {
      print('Profile Updated Successfully.');
    } else {
      print('Failed to Update Profile.');
    }

    if (_currentPasswordController.text.isNotEmpty && _newPasswordController.text.isNotEmpty) {
      bool passwordChangeSuccess = await firebaseInfoProfile.changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      if (passwordChangeSuccess) {
        print('Password Changed Successfully.');
      } else {
        print('Failed to Change Password.');
      }
    }

    Map<String, dynamic>? updatedUserData = await FirebaseProfileInformation().fetchCurrentUserProfile();

    setState(() {
      _isLoading = false;
    });

    if (updatedUserData != null) {
      Navigator.of(context).pop(updatedUserData);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<bool> _validateCurrentPassword() async {
    FirebaseProfileInformation firebaseInfoProfile = FirebaseProfileInformation();
    return await firebaseInfoProfile.verifyCurrentPassword(_currentPasswordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
        centerTitle: true,
        title: const Text('Edit Profile'),
        backgroundColor: const Color.fromARGB(255, 96, 88, 180),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                )
              : IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _hasChanges ? () async {
                    if (_formKey.currentState!.validate()) {
                      if (_currentPasswordController.text.isNotEmpty || _newPasswordController.text.isNotEmpty) {
                        if (await _validateCurrentPassword()) {
                          _confirmChanges();
                        } else {
                          setState(() {
                            _isCurrentPasswordValid = false;
                          });
                          _formKey.currentState!.validate();
                        }
                      } else {
                        _confirmChanges();
                      }
                    }
                  } : null,
                ),
        ],
      ),
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: Container(
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
          child: Form(
            key: _formKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0, left: 16.0),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: MediaQuery.of(context).size.height * 0.15,
                                backgroundImage: _getImage(),
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.camera_alt, color: Colors.black),
                                  onPressed: _pickImage,
                                ),
                              ),
                            ],
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
                            controller: _phoneNumberController,
                            label: 'Phone Number',
                          ),
                          const SizedBox(height: 24),
                          _buildTextFormField(
                            controller: _currentPasswordController,
                            label: 'Current Password',
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return null;
                              } else if (!_isCurrentPasswordValid) {
                                return 'Incorrect current password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          _buildTextFormField(
                            controller: _newPasswordController,
                            label: 'New Password',
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return null;
                              } else if (value.length < 6) {
                                return 'Password must be at least 6 characters long';
                              }
                              return null;
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
        ),
      ),
    );
  }
}
