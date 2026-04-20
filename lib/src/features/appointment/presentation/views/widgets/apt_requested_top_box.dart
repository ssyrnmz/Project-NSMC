import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/appointment.dart';

class AppointmentRequestedTopBox extends StatelessWidget {
  final Appointment appointment;
  final String name;
  final void Function(Appointment)? onTap;

  const AppointmentRequestedTopBox({
    super.key,
    required this.appointment,
    required this.name,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      child: _AppointmentCard(
        onTap: () => onTap?.call(appointment),
        name: name,
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final VoidCallback onTap;
  final String name;

  const _AppointmentCard({required this.onTap, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FF), // Soft pastel blue
        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: const Color(0xFFD6E0FF), // Light border tone
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBFC8FF).withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
          child: SizedBox(
            //height: 100,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Appointment name
                  Text(
                    (name.compareTo('') == 0) ? 'Unknown' : name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1C2C),
                    ),
                  ),

                  // History + icon together
                  Row(
                    children: [
                      Text(
                        'History',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFF1A1C2C),
                        ),
                      ),
                      const SizedBox(
                        width: 6,
                      ), // small gap between text and icon
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF7C8AFF),
                        size: 22,
                      ),
                    ],
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
