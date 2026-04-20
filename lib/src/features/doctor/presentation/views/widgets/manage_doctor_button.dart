import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Color palette definitions
const Color _accentBlue = Color(0xFF4A90E2);
const Color _lightGrey = Color(0xFFF0F0F0);
const Color _dangerRed = Color(0xFFD32F2F);

class ManagementDoctorButton extends StatefulWidget {
  final VoidCallback onAdd;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ManagementDoctorButton({
    super.key,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<ManagementDoctorButton> createState() => _ManagementDoctorButtonState();
}

class _ManagementDoctorButtonState extends State<ManagementDoctorButton> {
  // Custom Tiles Widget used to Create Modal Bottom Sheet
  Widget buttonActionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.black87,
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Close the sheet first
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(bottom: BorderSide(color: _lightGrey, width: 1))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: color,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modal Bottom Sheet function used when called
  void _showMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      // Use a higher radius for a more modern look
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),

              // 2. Action Tiles
              buttonActionTile(
                title: "Add New Doctor",
                icon: Icons.add_circle_outline,
                onTap: widget.onAdd,
              ),
              buttonActionTile(
                title: "Edit Doctor",
                icon: Icons.edit_outlined,
                onTap: widget.onEdit,
              ),
              // Delete without bottom divider
              buttonActionTile(
                title: "Deactivate Doctor",
                icon: Icons.delete_outline,
                color: _dangerRed,
                onTap: widget.onDelete,
                showDivider: false, // <-- prevents the bottom border
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.5, bottom: 0.0),
      child: Container(
        height: 40,
        width: 140,
        decoration: BoxDecoration(
          // Adjusted border for a softer look
          border: Border.all(color: _accentBlue.withOpacity(0.4), width: 1.0),
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _accentBlue.withOpacity(0.12), // Slightly stronger shadow
              blurRadius: 100,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: _showMenu,
            splashColor: _accentBlue.withOpacity(0.15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.tune,
                  color: _accentBlue,
                  size: 24,
                ), // Changed icon to tune for better management visual
                const SizedBox(width: 6),
                Text(
                  'Manage',
                  style: GoogleFonts.poppins(
                    color: _accentBlue,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
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
