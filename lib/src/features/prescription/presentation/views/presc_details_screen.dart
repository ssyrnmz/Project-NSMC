// Info: Screen to display full details of a single prescription,
// including a button to view the attached PDF (view-only — opens in
// in-app browser; server sends Content-Disposition: inline so the PDF
// renders without any download/save option).
// Uses url_launcher (already in project) — no new packages required.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/prescription.dart';
import '../../data/prescription_repository.dart';

class PrescDetailsScreen extends StatelessWidget {
  const PrescDetailsScreen({super.key, required this.prescription});
  final Prescription prescription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFf9fafb),
        elevation: 0,
        surfaceTintColor: const Color.fromARGB(255, 200, 200, 200),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4D7C4A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Prescription Details',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1E1E1E),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE6E6E6), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌸 Prescription Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0D6FF), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD9CCFF).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text("Prescribed Date",
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800])),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMMM yyyy')
                                .format(prescription.prescribedDate),
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87),
                          ),
                        ],
                      ),
                      const Icon(Icons.calendar_today_outlined,
                          color: Color(0xFF7A5CFA), size: 18),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Doctor",
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800])),
                          const SizedBox(height: 3),
                          Text(prescription.doctorName,
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black87)),
                        ],
                      ),
                      const Icon(Icons.medical_information_outlined,
                          color: Color(0xFF7A5CFA), size: 18),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── PDF view tile ────────────────────────────────────────────
            if (prescription.prescriptionFile != null &&
                prescription.prescriptionFile!.isNotEmpty)
              _PrescriptionPdfTile(prescription: prescription),

            const SizedBox(height: 8),

            // 💊 Medications header
            Padding(
              padding: const EdgeInsets.only(left: 1.5, top: 10, bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.medical_services_outlined,
                      color: Color(0xFF6B8BCE), size: 21),
                  const SizedBox(width: 7),
                  Text(
                    'Medication Prescribed',
                    style: GoogleFonts.poppins(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4A4A4A)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Container(height: 1, color: const Color(0xFFE5E5E5))),
                ],
              ),
            ),

            const SizedBox(height: 10),

            if (prescription.medications.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('No medications recorded.',
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.grey)),
              )
            else
              Column(
                children:
                    prescription.medications.map((m) => _MedBox(medication: m)).toList(),
              ),

            const SizedBox(height: 23),

            // 📝 Doctor's notes
            if (prescription.doctorNotes != null &&
                prescription.doctorNotes!.trim().isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FBFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDBE7FF), width: 1),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 5,
                      decoration: const BoxDecoration(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(12)),
                        gradient: LinearGradient(
                          colors: [Color(0xFF7C91F9), Color(0xFFBBA6FF)],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Row(
                        children: [
                          const Icon(Icons.article_outlined,
                              color: Color(0xFF6B8BCE), size: 20),
                          const SizedBox(width: 7),
                          Text("Doctor's Notes",
                              style: GoogleFonts.poppins(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF4A4A4A))),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Divider(thickness: 0.7, color: Color(0xFFD1D1D1)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
                      child: Text(
                        prescription.doctorNotes!,
                        style: GoogleFonts.poppins(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF2C2C2C),
                            height: 1.6),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── PDF tile — opens signed URL in in-app browser (view-only) ─────────────────
class _PrescriptionPdfTile extends StatelessWidget {
  const _PrescriptionPdfTile({required this.prescription});
  final Prescription prescription;

  Future<void> _openPdf(BuildContext context) async {
    final repo = context.read<PrescriptionRepository>();
    final url  = Uri.parse(repo.buildViewUrl(prescription.id));

    // LaunchMode.inAppBrowserView opens inside the app without the OS share/save
    // sheet — the server's Content-Disposition: inline prevents download.
    final launched = await launchUrl(url, mode: LaunchMode.inAppBrowserView);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open prescription file.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.picture_as_pdf, color: Colors.red.shade400, size: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Prescription File',
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E1E1E))),
                      const SizedBox(height: 2),
                      Text('Tap to view — cannot be downloaded',
                          style: GoogleFonts.poppins(
                              fontSize: 11.5, color: Colors.grey[500])),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFCC02)),
                  ),
                  child: Text('View Only',
                      style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFF57C00))),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openPdf(context),
                icon: const Icon(Icons.visibility_outlined,
                    size: 18, color: Color(0xFF4D7C4A)),
                label: Text('View Prescription',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4D7C4A))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF4D7C4A)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF8E1),
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline,
                    size: 13, color: Color(0xFFF57C00)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'This document is for viewing only and cannot be downloaded or saved.',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: const Color(0xFF5D4037)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Medication card widget ─────────────────────────────────────────────────────
class _MedBox extends StatelessWidget {
  const _MedBox({required this.medication});
  final Medication medication;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E5E5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(medication.name,
                  style: GoogleFonts.poppins(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E3A8A))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(medication.quantity,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4F46E5))),
              ),
            ],
          ),
          if (medication.instructions.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(medication.instructions,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[700])),
          ],
        ],
      ),
    );
  }
}
