import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Appointment card (standalone, no nested scrollview)
class AppointmentCard extends StatelessWidget {
  final String name;
  final String date;
  final String time;
  final String doctor;
  final VoidCallback onTap;

  const AppointmentCard({
    super.key,
    required this.name,
    required this.date,
    required this.time,
    required this.doctor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F6FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD6E0FF), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFBFC8FF).withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1C2C),
              ),
            ),

            const SizedBox(height: 12),
            Container(height: 1, color: const Color(0xFFE1E6FF)),
            const SizedBox(height: 12),

            _buildDetailRow(icon: Icons.calendar_today_outlined, text: date),

            const SizedBox(height: 8),

            _buildDetailRow(icon: Icons.access_time, text: time),

            const SizedBox(height: 8),

            _buildDetailRow(
              icon: Icons.person_outline,
              text: 'Doctor: $doctor',
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFF7C8AFF),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF4C6FFF)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
