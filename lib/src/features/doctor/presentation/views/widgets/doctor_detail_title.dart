import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildDoctorDetailTitle({
  required BuildContext context,
  required String screenTitle,
  required Widget doctorListScreen,
}) {
  return Scaffold(
    backgroundColor: const Color(0xFFf9fafb),
    appBar: AppBar(
      backgroundColor: const Color(0xFFFFFFFF),
      elevation: 0,
      surfaceTintColor: const Color.fromARGB(235, 165, 165, 165),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4D7C4A)),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        screenTitle,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: const Color(0xFF1E1E1E),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: const Color(0xFFE6E6E6), // light grey divider
          height: 1,
        ),
      ),
    ),
    body: SingleChildScrollView(
      child: Column(
        children: [
          Padding(padding: const EdgeInsets.all(0.0), child: doctorListScreen),
        ],
      ),
    ),
  );
}
