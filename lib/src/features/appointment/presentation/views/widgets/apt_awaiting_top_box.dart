import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class AwaitingTopBox extends StatelessWidget {
  const AwaitingTopBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 29.0),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Confirm Your Appointment',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
