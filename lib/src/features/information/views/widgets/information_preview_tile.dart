import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class InfoPreviewTile extends StatelessWidget {
  final String title;
  final String message;
  final bool isRead;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final DateTime? date; // NEW: notification date

  const InfoPreviewTile({
    super.key,
    required this.title,
    required this.message,
    required this.onTap,
    this.isRead = false,
    this.onDelete,
    this.icon = Icons.email_rounded,
    this.iconColor = Colors.white,
    this.iconBgColor = const Color(0xFFB6D8F9),
    this.date,
  });

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    if (d == today) return 'Today, ${DateFormat('hh:mm a').format(dt)}';
    if (d == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${DateFormat('hh:mm a').format(dt)}';
    }
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 28),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : const Color(0xFFF0F6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRead
                  ? const Color(0xFFEEEEEE)
                  : const Color(0xFFBDD4F8),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon with unread dot
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: iconBgColor,
                    child: Icon(icon, color: iconColor, size: 26),
                  ),
                  if (!isRead)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E72E8),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 14),

              // Title + Message + Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight:
                            isRead ? FontWeight.w500 : FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      message.length > 75
                          ? '${message.substring(0, 75)}...'
                          : message,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color:
                            isRead ? Colors.grey[600] : Colors.grey[800],
                        height: 1.4,
                      ),
                    ),
                    if (date != null) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 12, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(date!),
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: Colors.grey[400],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 6),

              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(Icons.close_rounded,
                        color: Colors.grey[400], size: 18),
                  ),
                )
              else
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.grey, size: 15),
            ],
          ),
        ),
      ),
    );
  }
}