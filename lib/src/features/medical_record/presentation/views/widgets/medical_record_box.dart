import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../config/constants/global_values.dart';

class MedicalRecordBox extends StatelessWidget {
  final String date;
  final String description;
  final UserRole role;
  final bool verified;
  final bool rejected;
  final VoidCallback? onDelete;
  final VoidCallback? onDownload;

  const MedicalRecordBox({
    super.key,
    required this.date,
    required this.description,
    required this.role,
    required this.verified,
    this.rejected = false,
    this.onDelete,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF9FBFF), Color(0xFFEFF6FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9E6FF), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90CAF9).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.feed_rounded,
                    size: 28,
                    color: Color(0xFF42A5F5),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Date & description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E3A8A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF4B5563),
                        height: 1.4,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Status badge — admin only
                    if (role == UserRole.admin) ...[
                      const SizedBox(height: 6),
                      _StatusBadge(verified: verified, rejected: rejected),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Action icons
              Row(
                children: [
                  // Download only if verified OR admin
                  if (verified || role == UserRole.admin)
                    GestureDetector(
                      onTap: onDownload,
                      child: const Icon(
                        Icons.file_download_outlined,
                        color: Color(0xFF6FBF73),
                        size: 24,
                      ),
                    ),

                  if (role == UserRole.admin) ...[
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(
                        Icons.delete_forever_rounded,
                        color: Colors.red,
                        size: 26,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Status badge widget ──────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final bool verified;
  final bool rejected;

  const _StatusBadge({required this.verified, this.rejected = false});

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color borderColor;
    final Color textColor;
    final IconData icon;
    final String label;

    if (verified) {
      bgColor     = const Color(0xFFE8F5E9);
      borderColor = const Color(0xFF66BB6A);
      textColor   = const Color(0xFF2E7D32);
      icon        = Icons.check_circle_outline;
      label       = 'Verified';
    } else if (rejected) {
      bgColor     = const Color(0xFFFFEBEE);
      borderColor = const Color(0xFFEF9A9A);
      textColor   = const Color(0xFFD32F2F);
      icon        = Icons.cancel_outlined;
      label       = 'Rejected';
    } else {
      bgColor     = const Color(0xFFFFF8E1);
      borderColor = const Color(0xFFFFCC02);
      textColor   = const Color(0xFFF9A825);
      icon        = Icons.hourglass_empty;
      label       = 'Pending Verification';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}