import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildDoctorDetailRow({
  required String text1,
  String? text2,
  String? text3,
  String? text4,
  String? imagePath,
  Color backgroundColor = Colors.white,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
    child: Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 5,
            offset: const Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left accent indicator
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: Color(0xFF4268F6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),

          // Content area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main header
                  Text(
                    text1,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1D1F),
                      height: 1.4,
                    ),
                  ),

                  // Full width divider that extends from side to side
                  Container(
                    width: double.infinity,
                    height: 1.5,
                    margin: const EdgeInsets.only(top: 12, bottom: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),

                  // Details section
                  if (text2 != null || text3 != null || text4 != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (text2 != null) _buildDetailItem(text2),
                        if (text3 != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: _buildDetailItem(text3),
                          ),
                        if (text4 != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: _buildDetailItem(text4),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// Helper widget for detail items
Widget _buildDetailItem(String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 4.0, right: 10.0),
        child: Icon(Icons.circle, size: 6, color: Color(0xFF6B7280)),
      ),
      Expanded(
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
      ),
    ],
  );
}
