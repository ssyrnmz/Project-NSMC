import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientDetailsIllust extends StatelessWidget {
  const PatientDetailsIllust({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/search_patient.png',
            width: 250,
            height: 250,
            fit: BoxFit.contain,
          ),

          Transform.translate(
            offset: const Offset(0, -30),
            child: Text(
              'Start your search here',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w300,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
