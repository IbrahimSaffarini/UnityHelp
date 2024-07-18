import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton {
  static Widget buildButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isEnabled = true,
    bool isLoading = false,
    bool isSuccess = false,
  }) {
    final Color textColor = isEnabled ? const Color.fromARGB(255, 98, 89, 188) : Colors.white;
    final Color iconColor = isEnabled ? const Color.fromARGB(255, 98, 89, 188) : Colors.white;
    final Color backgroundColor = isEnabled ? Colors.white : Colors.grey;

    return ElevatedButton.icon(
      icon: isLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: iconColor,
                strokeWidth: 2.0,
              ),
            )
          : isSuccess
              ? Icon(Icons.check_circle, color: iconColor,)
              : Icon(icon, color: iconColor),
      label: isLoading || isSuccess
          ? const SizedBox.shrink()
          : Text(
              label,
              style: GoogleFonts.rubik(fontSize: 25, color: textColor),
            ),
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        elevation: 2.0,
      ),
    );
  }
}
