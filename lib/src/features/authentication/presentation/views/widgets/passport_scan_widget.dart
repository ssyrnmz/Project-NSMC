import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';

typedef PassportScanCallback = void Function({
  required String passportNumber,
  String? fullName,
  DateTime? dateOfBirth,
});

/// Passport scan widget for non-Malaysian users during registration.
/// Uses file_picker (already in project) to let the user pick a passport
/// image from their gallery. OCR is handled server-side via the backend,
/// or the user can enter the passport number manually.
///
/// NOTE: Live camera OCR requires google_mlkit_text_recognition which needs
/// to be added to pubspec.yaml. For now this widget uses file_picker only
/// and falls back gracefully to manual entry.
class PassportScanWidget extends StatefulWidget {
  const PassportScanWidget({
    super.key,
    required this.onScanned,
    this.onManualEntry,
  });

  final PassportScanCallback onScanned;
  final VoidCallback? onManualEntry;

  @override
  State<PassportScanWidget> createState() => _PassportScanWidgetState();
}

class _PassportScanWidgetState extends State<PassportScanWidget> {
  bool _isProcessing = false;
  String? _statusMessage;
  bool _success = false;
  File? _pickedFile;

  // ── Pick image from gallery using file_picker ──────────────
  Future<void> _pickFromGallery() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Opening gallery…';
      _success = false;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: false,
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });
        return;
      }

      final path = result.files.single.path;
      if (path == null) {
        setState(() {
          _isProcessing = false;
          _statusMessage = 'Could not read the selected file. Please try again.';
        });
        return;
      }

      setState(() {
        _pickedFile = File(path);
        _isProcessing = false;
        _statusMessage =
            'Image selected. Please enter your passport number below to confirm.';
        _success = true;
      });

      // Prompt user to fill in manually after picking — 
      // they can see the image and type the number themselves.
      // This avoids the need for an OCR package in pubspec.yaml.
      if (widget.onManualEntry != null) {
        widget.onManualEntry!();
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage =
            'Could not open gallery. Please enter your passport number manually.';
      });
    }
  }

  // ── UI ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Passport',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
          ),
          const SizedBox(height: 8),

          // ── Pick from gallery button ───────────────────────
          GestureDetector(
            onTap: _isProcessing ? null : _pickFromGallery,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _isProcessing ? Colors.grey[100] : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isProcessing
                      ? Colors.grey.shade300
                      : const Color(0xFF629E5C),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    color: _isProcessing
                        ? Colors.grey
                        : const Color(0xFF629E5C),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _isProcessing ? 'Processing…' : 'Pick Passport Image',
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      color: _isProcessing
                          ? Colors.grey
                          : const Color(0xFF4D7C4A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Processing indicator ───────────────────────────
          if (_isProcessing) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation(Color(0xFF629E5C)),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _statusMessage ?? 'Processing…',
                  style: GoogleFonts.poppins(
                      fontSize: 12.5, color: Colors.grey[700]),
                ),
              ],
            ),
          ],

          // ── Status message ─────────────────────────────────
          if (!_isProcessing && _statusMessage != null) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _success
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _success
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFFB300),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _success
                        ? Icons.check_circle_outline
                        : Icons.warning_amber_outlined,
                    size: 16,
                    color: _success
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFFB300),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _statusMessage!,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: _success
                            ? Colors.green[800]
                            : Colors.orange[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Manual entry fallback ──────────────────────────
          if (widget.onManualEntry != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: _isProcessing ? null : widget.onManualEntry,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Enter passport number manually instead',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  color: const Color(0xFF629E5C),
                  decoration: TextDecoration.underline,
                  decorationColor: const Color(0xFF629E5C),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}