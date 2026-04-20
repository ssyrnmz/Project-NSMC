// Simplified Admin prescription screen — PDF upload + basic info only.
// Medications are optional and kept for completeness but not required.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:intl/intl.dart';

import '../viewmodels/presc_modify_viewmodel.dart';
import '../viewmodels/presc_view_viewmodel.dart';
import '../../domain/prescription.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../../utils/data/results.dart';
import '../../../../utils/ui/show_snackbar.dart';
import '../../../../utils/ui/show_success_dialogue.dart';

class PrescModifyScreen extends StatefulWidget {
  const PrescModifyScreen({
    super.key,
    required this.userId,
    this.prescription,
  });

  final String userId;
  final Prescription? prescription;

  @override
  State<PrescModifyScreen> createState() => _PrescModifyScreenState();
}

class _PrescModifyScreenState extends State<PrescModifyScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _doctorNameCtrl;
  late TextEditingController _notesCtrl;
  DateTime? _prescribedDate;
  String _status = 'current';

  // PDF
  File? _pdfFile;
  String? _existingPdfName;

  // Medications (optional)
  List<_MedicationEntry> _medications = [];

  bool get _isEditMode => widget.prescription != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final p = widget.prescription!;
      _doctorNameCtrl  = TextEditingController(text: p.doctorName);
      _notesCtrl       = TextEditingController(text: p.doctorNotes ?? '');
      _prescribedDate  = p.prescribedDate;
      _status          = p.status;
      _existingPdfName = p.prescriptionFile;
      _medications     = p.medications
          .map((m) => _MedicationEntry(
                name: m.name,
                quantity: m.quantity,
                instructions: m.instructions,
              ))
          .toList();
    } else {
      _doctorNameCtrl = TextEditingController();
      _notesCtrl      = TextEditingController();
    }
  }

  @override
  void dispose() {
    _doctorNameCtrl.dispose();
    _notesCtrl.dispose();
    for (final m in _medications) m.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showRoundedDatePicker(
      context: context,
      initialDate: _prescribedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      borderRadius: 16,
      height: 301,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF629E5C),
          onPrimary: Colors.white,
          onSurface: Colors.black87,
        ),
        dialogBackgroundColor: Colors.white,
      ),
    );
    if (picked != null) setState(() => _prescribedDate = picked);
  }

  Future<void> _pickPDF() async {
    final vmModify = context.read<PrescriptionModifyViewModel>();
    final result   = await vmModify.pickPDF();
    if (!mounted) return;
    switch (result) {
      case Ok<File?>():
        if (result.value != null) setState(() => _pdfFile = result.value);
      case Error<File?>():
        showSnackBar(
          context: context,
          text: vmModify.message ?? 'Failed to pick PDF.',
          color: Colors.red[900],
        );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_prescribedDate == null) {
      showSnackBar(
        context: context,
        text: 'Please select a prescribed date.',
        color: Colors.red[900],
      );
      return;
    }

    final medications = _medications
        .map((m) => Medication(
              name: m.nameCtrl.text.trim(),
              quantity: m.quantityCtrl.text.trim(),
              instructions: m.instructionsCtrl.text.trim(),
            ))
        .toList();

    final prescription = Prescription(
      id: _isEditMode ? widget.prescription!.id : 0,
      prescribedDate: _prescribedDate!,
      doctorName: _doctorNameCtrl.text.trim(),
      doctorNotes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      medications: medications,
      status: _status,
      userId: widget.userId,
      updatedAt: DateTime.now().toUtc(),
      prescriptionFile: _existingPdfName,
    );

    final vmModify = context.read<PrescriptionModifyViewModel>();
    final vmView   = context.read<PrescriptionViewModel>();

    final result = _isEditMode
        ? await vmModify.editPrescription(prescription, pdfFile: _pdfFile)
        : await vmModify.addPrescription(prescription, pdfFile: _pdfFile);

    if (!mounted) return;

    if (result is Error) {
      showSnackBar(
        context: context,
        text: vmModify.message ?? 'An error occurred. Please try again.',
        color: Colors.red[900],
      );
      return;
    }

    await vmView.load(widget.userId);
    if (!mounted) return;

    showSuccessDialog(
      context: context,
      title: 'Success!',
      message: _isEditMode
          ? 'Prescription updated successfully.'
          : 'Prescription added successfully.',
      buttonText: 'Back',
      onButtonPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vmModify = context.watch<PrescriptionModifyViewModel>();

    return LoadingOverlay(
      isLoading: vmModify.isLoading,
      child: Scaffold(
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
            _isEditMode ? 'Edit Prescription' : 'Add Prescription',
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
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── PDF Upload (prominent at top) ─────────────────────────
                _buildLabel('Prescription PDF'),
                const SizedBox(height: 8),
                _buildPdfPicker(),
                const SizedBox(height: 6),
                Text(
                  'Upload the prescription as a PDF file.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Date ─────────────────────────────────────────────────
                _buildLabel('Prescribed Date'),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _prescribedDate == null
                              ? 'DD/MM/YYYY'
                              : DateFormat('dd/MM/yyyy').format(_prescribedDate!),
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: _prescribedDate == null
                                ? const Color(0xFF757575)
                                : Colors.black,
                          ),
                        ),
                        const Icon(Icons.calendar_today,
                            size: 20, color: Color.fromARGB(255, 143, 179, 140)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Doctor Name ───────────────────────────────────────────
                _buildLabel('Prescribed By (Doctor Name)'),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _doctorNameCtrl,
                  hintText: 'Enter doctor name',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Doctor name is required.' : null,
                ),
                const SizedBox(height: 16),

                // ── Status ────────────────────────────────────────────────
                _buildLabel('Status'),
                const SizedBox(height: 6),
                _buildStatusDropdown(),
                const SizedBox(height: 16),

                // ── Notes (optional) ─────────────────────────────────────
                _buildLabel("Doctor's Notes (Optional)"),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _notesCtrl,
                  hintText: "Enter any notes (optional)",
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // ── Medications (optional) ────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('Medications (Optional)'),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _medications.add(_MedicationEntry())),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text('Add', style: GoogleFonts.poppins(fontSize: 13)),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
                if (_medications.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  for (int i = 0; i < _medications.length; i++)
                    _buildMedicationCard(i),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'No medications added. Tap Add if needed.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // ── Save Button ───────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6FBF73),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _save,
                    child: Text(
                      _isEditMode ? 'Update Prescription' : 'Save Prescription',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPdfPicker() {
    final hasNew      = _pdfFile != null;
    final hasExisting = _existingPdfName != null && !hasNew;
    final label = hasNew
        ? _pdfFile!.path.split('/').last
        : hasExisting
            ? _existingPdfName!
            : 'Tap to upload prescription PDF';

    return GestureDetector(
      onTap: _pickPDF,
      child: Container(
        height: 64,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: hasNew || hasExisting
              ? const Color(0xFFF1FFF1)
              : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasNew || hasExisting
                ? const Color(0xFF629E5C)
                : const Color(0xFFE0E0E0),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.picture_as_pdf_rounded,
              color: hasNew || hasExisting ? Colors.red.shade400 : Colors.grey,
              size: 30,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: hasNew || hasExisting ? Colors.black87 : Colors.grey[600],
                ),
              ),
            ),
            Icon(
              hasNew || hasExisting ? Icons.check_circle : Icons.upload_file,
              color: hasNew || hasExisting
                  ? const Color(0xFF629E5C)
                  : Colors.grey,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.black, fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF629E5C), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _status,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF629E5C), width: 1.5),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'current', child: Text('Current')),
        DropdownMenuItem(value: 'history', child: Text('History')),
      ],
      onChanged: (val) {
        if (val != null) setState(() => _status = val);
      },
    );
  }

  Widget _buildMedicationCard(int i) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9FBFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD9E6FF), width: 1.2),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Medication ${i + 1}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _medications.removeAt(i)),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.shade100,
                    ),
                    child: const Icon(Icons.close, size: 16, color: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildLabel('Name'),
            const SizedBox(height: 4),
            _buildTextField(
              controller: _medications[i].nameCtrl,
              hintText: 'Medication name',
            ),
            const SizedBox(height: 8),
            _buildLabel('Quantity'),
            const SizedBox(height: 4),
            _buildTextField(
              controller: _medications[i].quantityCtrl,
              hintText: 'e.g. 500 mg / 2 tablets',
            ),
            const SizedBox(height: 8),
            _buildLabel('Instructions'),
            const SizedBox(height: 4),
            _buildTextField(
              controller: _medications[i].instructionsCtrl,
              hintText: 'e.g. Take one tablet every 8 hours',
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicationEntry {
  final TextEditingController nameCtrl;
  final TextEditingController quantityCtrl;
  final TextEditingController instructionsCtrl;

  _MedicationEntry({
    String name         = '',
    String quantity     = '',
    String instructions = '',
  })  : nameCtrl         = TextEditingController(text: name),
        quantityCtrl     = TextEditingController(text: quantity),
        instructionsCtrl = TextEditingController(text: instructions);

  void dispose() {
    nameCtrl.dispose();
    quantityCtrl.dispose();
    instructionsCtrl.dispose();
  }
}
