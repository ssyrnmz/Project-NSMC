import 'package:flutter/material.dart';
import 'package:flutter_application_2/src/core/widgets/loading_screen.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'dart:io';

import '../viewmodels/mr_upload_viewmodel.dart';
import '../viewmodels/mr_view_viewmodel.dart';
import '../../domain/medical_record.dart';
import '../../../../utils/ui/display_formatters.dart';
import '../../../../utils/ui/show_success_dialogue.dart';
import '../../../../utils/ui/show_snackbar.dart';
import '../../../../utils/data/results.dart';

class MedicalRecordUploadScreen extends StatefulWidget {
  const MedicalRecordUploadScreen({
    super.key,
    required this.id,
    // ── NEW: Patient details for the ITD verification email ─────────────────
    this.patientName = '',
    this.patientEmail = '',
    this.patientIc = '',
  });

  final String id;
  final String patientName;
  final String patientEmail;
  final String patientIc;

  @override
  State<MedicalRecordUploadScreen> createState() =>
      _MedicalRecordUploadScreenState();
}

class _MedicalRecordUploadScreenState
    extends State<MedicalRecordUploadScreen> {
  //▫️Variable:
  late TextEditingController _titleController;

  DateTime? _date;
  File? _file;

  //▫️State initialization & disposal:
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final vmModify = context.watch<MedicalRecordUploadViewModel>();
    final vmData = context.read<MedicalRecordViewModel>();

    return LoadingOverlay(
      isLoading: vmModify.isLoading,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: AppBar(
          backgroundColor: const Color(0xFFf9fafb),
          elevation: 0,
          surfaceTintColor: const Color.fromARGB(255, 200, 200, 200),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF4D7C4A),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Upload Medical Report',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── Patient info banner (so admin can confirm who they're uploading for) ──
              if (widget.patientName.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7F0),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF6FBF73)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person,
                        color: Color(0xFF4D7C4A),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.patientName,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: const Color(0xFF1E1E1E),
                              ),
                            ),
                            if (widget.patientIc.isNotEmpty)
                              Text(
                                'IC: ${widget.patientIc}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF757575),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      " File",
                      style: GoogleFonts.poppins(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),

                    GestureDetector(
                      onTap: () async {
                        final result = await vmModify.pickPDF();

                        if (!context.mounted) return;

                        switch (result) {
                          case Ok<File?>():
                            final file = result.value;
                            late final String message;

                            if (file != null) {
                              setState(() {
                                _file = file;
                              });
                              message = "PDF file successfully picked.";
                            } else {
                              message = "No file was picked.";
                            }

                            showSnackBar(context: context, text: message);
                          case Error<File?>():
                            showSnackBar(
                              context: context,
                              text:
                                  vmModify.message ??
                                  "An unknown error occured. Please try again.",
                              color: Colors.red[900],
                            );
                        }
                      },
                      child: Container(
                        height: 60,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red.shade400,
                              size: 28,
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Text(
                                  _file == null
                                      ? "Tap to upload report (PDF)"
                                      : _file!.path.split('/').last,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF757575),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),

                            const Icon(
                              Icons.edit,
                              size: 20,
                              color: Color(0xFF6FBF73),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              buildDateField(vmModify, context),
              buildContentSection(vmModify),

              // ── Verification notice ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFCC02)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFFF9A825),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'After uploading, a verification email will be sent to ITD. '
                          'The patient will only be able to view this report after ITD approves it.',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: const Color(0xFF5D4037),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6FBF73),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),

                      onPressed: () async {
                        if (_titleController.text.isNotEmpty &&
                            _titleController.text != '' &&
                            _date != null &&
                            _file != null) {
                          final saveData = MedicalRecord(
                            id: 0,
                            name: _titleController.text.trim(),
                            date: _date!,
                            file: '',
                            userId: widget.id,
                            archived: false,
                            updatedAt: DateTime.timestamp(),
                          );

                          // ── Pass patient info so ITD email can be sent ────
                          final result = await vmModify.createRecord(
                            saveData,
                            _file!,
                            patientName: widget.patientName,
                            patientEmail: widget.patientEmail,
                            patientIc: widget.patientIc,
                          );

                          if (!context.mounted) return;

                          switch (result) {
                            case Ok():
                              showSuccessDialog(
                                context: context,
                                title: "Medical Record Uploaded!",
                                // ── Updated message to mention verification ──
                                message:
                                    "The ${saveData.name} has been uploaded successfully. "
                                    "A verification email has been sent to ITD. "
                                    "The patient will be able to view this report once it is approved.",
                                onButtonPressed: () {
                                  vmData.load(saveData.userId);
                                  Navigator.of(context).popUntil((route) {
                                    return route.settings.name ==
                                            '/recordList' ||
                                        route.isFirst;
                                  });
                                },
                              );

                            case Error():
                              showSnackBar(
                                context: context,
                                text:
                                    vmModify.message ??
                                    "An unknown error occured. Please try again.",
                                color: Colors.red[900],
                              );
                          }
                        }
                      },
                      child: Text(
                        'Upload Report',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  //▫️Helper Widgets:
  Widget buildContentSection(MedicalRecordUploadViewModel vmModify) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTextField(
            label: " Title",
            controller: _titleController,
            hintText: "Enter Record's Title",
          ),
        ],
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 15.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.black, fontSize: 15),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF757575),
                fontSize: 15,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDateField(
    MedicalRecordUploadViewModel vmModify,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            " Date",
            style: GoogleFonts.poppins(
              fontSize: 15.5,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),

          GestureDetector(
            onTap: () async {
              DateTime? pickedDate = await showRoundedDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1920),
                lastDate: DateTime.now(),
                borderRadius: 16,
                height: 301,
                theme: ThemeData(
                  primaryColor: const Color(0xFFFFFFFF),
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF629E5C),
                    onPrimary: Colors.white,
                    onSurface: Colors.black87,
                  ),
                  dialogBackgroundColor: Colors.white,
                ),
              );
              if (pickedDate != null) {
                setState(() => _date = pickedDate);
              }
            },
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
                    (_date != null)
                        ? DisplayFormat().date(_date!)
                        : "DD/MM/YYYY",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: _date == null
                          ? const Color(0xFF757575)
                          : Colors.black,
                      fontStyle: _date == null
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),

                  const Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: Color.fromARGB(255, 143, 179, 140),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
