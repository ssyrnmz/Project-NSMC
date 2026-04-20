import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Color palette definitions
const Color _accentBlue = Color(0xFF4A90E2);
const Color _lightGrey = Color(0xFFF0F0F0);

class ManageHealthButton extends StatefulWidget {
  final VoidCallback onCarouselImage;
  final VoidCallback onHealthPackage;

  const ManageHealthButton({
    super.key,
    required this.onCarouselImage,
    required this.onHealthPackage,
  });

  @override
  State<ManageHealthButton> createState() => _ManageHealthPackageWidgetState();
}

class _ManageHealthPackageWidgetState extends State<ManageHealthButton> {
  // --- Custom Action Tile for the Bottom Sheet ---
  Widget _actionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.black87,
    bool showDivider = true, // <-- new parameter
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

  // --- Modal Bottom Sheet Logic ---
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
              _actionTile(
                title: "Manage Carousel Image",
                icon: Icons.view_carousel_outlined,
                onTap: widget.onCarouselImage,
              ),

              _actionTile(
                title: "Manage Health Package",
                icon: Icons.medical_services_outlined,
                onTap: widget.onHealthPackage,
                showDivider: false,
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
