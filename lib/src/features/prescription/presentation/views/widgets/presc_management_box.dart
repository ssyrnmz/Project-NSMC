// Info: Widget for displaying a single prescription item in the list.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PrescManagementBox extends StatelessWidget {
  final String title; // Prescription date label
  final String subtitle; // Medication summary
  final bool isAdmin;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const PrescManagementBox({
    super.key,
    required this.title,
    required this.subtitle,
    this.isAdmin = false,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 390),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left icon
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SvgPicture.asset(
                  'assets/svgs/medBlueT.svg',
                  width: 46,
                  height: 46,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),

              // Text section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2E4E2E),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.medication_rounded,
                          color: Color(0xFFff66c4),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            subtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Trash icon if admin
              if (isAdmin)
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.red,
                      size: 26,
                    ),
                    onPressed: onDelete,
                  ),
                ),

              // Right arrow icon
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
