import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppointmentBox extends StatelessWidget {
  final String date;
  final String time;
  final String doctor;
  final VoidCallback onTap; // 👈 optional tap function

  const AppointmentBox({
    super.key,
    required this.date,
    required this.time,
    required this.doctor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap, // 👈 tap on the whole container
        child: Container(
          constraints: const BoxConstraints(maxWidth: 390),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔹 Left side (logo)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SvgPicture.asset(
                  'assets/svg/cc2.svg',
                  width: 46,
                  height: 46,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),

              // 🔹 Text section (title + subtitle + rightTop)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      date,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2E4E2E),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Subtitle + RightTop in the same line
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          color: Color(0xFFff66c4),
                          size: 16,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          time,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    const SizedBox(height: 3),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.face_rounded,
                          color: Color(0xFF4294ff),
                          size: 16,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          'Doctor: $doctor',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 🔹 “>” Icon
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9E9E9E),
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
