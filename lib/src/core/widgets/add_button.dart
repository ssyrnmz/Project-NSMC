import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _accentBlue = Color(0xFF4A90E2);

class AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.5, bottom: 0.0),
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(color: _accentBlue.withOpacity(0.6), width: 1.2),
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _accentBlue.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: onTap,
            splashColor: _accentBlue.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '  Add  ',
                    style: GoogleFonts.poppins(
                      color: _accentBlue,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
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
