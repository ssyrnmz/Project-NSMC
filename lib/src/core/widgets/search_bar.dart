import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchBarWidget extends StatelessWidget {
  final VoidCallback onTapped;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.onTapped,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: GestureDetector(
        onTap: onTapped,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8FE3CF), Color(0xFF57CC99), Color(0xFF8FE3CF)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, right: 10.0),
                  child: Icon(
                    Icons.search_rounded,
                    size: 23,
                    color: Color(0xFF4D7C4A),
                  ),
                ),
                Expanded(
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade700,
                          letterSpacing: 0.2,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.only(
                          left: 0,
                          right: 8,
                          top: 14,
                          bottom: 14,
                        ),
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
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
