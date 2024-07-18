import 'dart:io';
import 'package:disaster_relief_application/Utility/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

Future<ImageSource?> showEditImageBottomSheet(BuildContext context, VoidCallback onRemoveImage) async {
  // Unfocus all text fields to dismiss the keyboard
  FocusScope.of(context).requestFocus(FocusNode());

  return await showModalBottomSheet<ImageSource?>(
    context: context,
    isScrollControlled: true, // Add this to make the bottom sheet scrollable
    builder: (context) {
      return EditImageBottomSheet(
        onRemoveImage: onRemoveImage,
      );
    },
  );
}

class EditImageBottomSheet extends StatelessWidget {
  final VoidCallback onRemoveImage;

  EditImageBottomSheet({super.key, required this.onRemoveImage});

  final double bottomSheetBottomSize = Platform.isIOS ? 30 : 10;

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
                      'What would you like to do ?',
                      style: GoogleFonts.notoSansKhudawadi(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton.buildButton(
                    label: 'Take Photo',
                    icon: Icons.camera,
                    onPressed: () => Navigator.of(context).pop(ImageSource.camera),
                  ),
                  const SizedBox(height: 20),
                  CustomButton.buildButton(
                    label: 'Pick from Gallery',
                    icon: Icons.photo_library,
                    onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
                  ),
                  const SizedBox(height: 20),
                  CustomButton.buildButton(
                    label: 'Remove Picture',
                    icon: Icons.delete,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onRemoveImage();
                    }
                  ),
                  SizedBox(height: bottomSheetBottomSize,)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
