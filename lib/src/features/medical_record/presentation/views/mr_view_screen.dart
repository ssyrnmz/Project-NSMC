import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'mr_upload_screen.dart';
import 'widgets/medical_record_box.dart';
import '../viewmodels/mr_view_viewmodel.dart';
import '../../../authentication/data/account_session.dart';
import '../../../../config/constants/global_values.dart';
import '../../../../core/widgets/account_checker.dart';
import '../../../../core/widgets/add_button.dart';
import '../../../../core/widgets/find_item_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../../core/widgets/search_bar.dart';
import '../../../../core/widgets/no_feature_screen.dart';
import '../../../../utils/data/results.dart';
import '../../../../utils/ui/animations_transitions.dart';
import '../../../../utils/ui/display_formatters.dart';
import '../../../../utils/ui/show_snackbar.dart';
import '../../../../utils/ui/show_delete_confirmation_dialogue.dart';

class MedicalRecordViewScreen extends StatefulWidget {
  const MedicalRecordViewScreen({
    super.key,
    this.id,
    // ── NEW: Patient details passed from the admin patient list screen ──────
    // These are forwarded to MedicalRecordUploadScreen so notify_itd.php can
    // include them in the verification email sent to portal@normah.com.
    this.patientName = '',
    this.patientEmail = '',
    this.patientIc = '',
  });

  final String? id;
  final String patientName;
  final String patientEmail;
  final String patientIc;

  @override
  State<MedicalRecordViewScreen> createState() =>
      _MedicalRecordViewScreenState();
}

class _MedicalRecordViewScreenState extends State<MedicalRecordViewScreen> {
  //▫️State initialization & disposal:
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vmInitial = context.read<MedicalRecordViewModel>();

      final result = await vmInitial.load(widget.id);

      if (!mounted) return;

      if (result is Error) {
        showSnackBar(
          context: context,
          text:
              vmInitial.message ??
              "An unknown error occured. Please try again.",
          color: Colors.red[900],
        );
      }
    });
  }

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final session = context.watch<AccountSession>();
    final vm = context.watch<MedicalRecordViewModel>();

    return LoadingOverlay(
      isLoading: vm.isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
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
            'Medical Report',
            style: GoogleFonts.poppins(
              color: const Color(0xFF1E1E1E),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(color: Color(0xFFE6E6E6), height: 1),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),

                //🔹Search bar that navigates correctly
                SearchBarWidget(
                  hintText: 'Search for your medical report',
                  onTapped: () {
                    Navigator.of(context).push(
                      transitionAnimation(
                        page: FindItemScreen(
                          hintText: 'Search for your medical report',
                          items: vm.searchList,
                          leadingIcon: Icons.description,
                          onItemSelected: (value) {
                            Navigator.pop(context);
                            vm.searchPicked(value);
                          },
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                //🔹Recent Reports header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.history_rounded,
                              color: Color(0xFF6B8BCE),
                              size: 20,
                            ),

                            const SizedBox(width: 8),

                            Text(
                              'Recent Reports',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4A4A4A),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Container(
                                height: 1,
                                color: const Color(0xFFE0E0E0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (session.role == UserRole.admin)
                        AddButton(
                          onTap: () {
                            final id = widget.id;

                            if (id != null) {
                              Navigator.of(context).push(
                                transitionAnimation(
                                  page: AuthWrappper(
                                    accessRole: UserRole.admin,
                                    // ── Pass patient details to upload screen ─
                                    child: MedicalRecordUploadScreen(
                                      id: id,
                                      patientName: widget.patientName,
                                      patientEmail: widget.patientEmail,
                                      patientIc: widget.patientIc,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                //🔹List showing medical reports using MedicalPDFBox
                //🔹List showing medical reports
                // Admin sees all; patient only sees verified ones
                if (vm.records.where((r) =>
                    session.role == UserRole.admin || r.verified).isNotEmpty)
                  ...vm.records
                    .where((r) => session.role == UserRole.admin || r.verified)
                    .map((report) {
                    return MedicalRecordBox(
                      date: DisplayFormat().date(report.date),
                      description: DisplayFormat().medicalRecordName(
                        report.name,
                      ),
                      role: session.role,
                      verified: report.verified,
                      rejected: report.rejected,
                      onDelete: (session.role == UserRole.admin)
                          ? () {
                              showDeleteConfirmationDialog(
                                context: context,
                                title: "Delete Report",
                                message:
                                    "Are you sure you want to delete this report? This action cannot be undone.",
                                confirmButtonText: "Yes, Delete",
                                successTitle: "Record Deleted!",
                                successMessage:
                                    "${report.name} has been successfully archived.",
                                onDelete: () async {
                                  final result = await vm.deleteRecord(report);

                                  if (!context.mounted) return;

                                  if (result is Error) {
                                    showSnackBar(
                                      context: context,
                                      text:
                                          vm.message ??
                                          "An unknown error occured. Please try again.",
                                      color: Colors.red[900],
                                    );
                                  }
                                },
                                whenDelete: () async {
                                  final result = await vm.load(widget.id);

                                  if (!context.mounted) return;

                                  if (result is Error) {
                                    showSnackBar(
                                      context: context,
                                      text:
                                          vm.message ??
                                          "An unknown error occured. Please try again.",
                                      color: Colors.red[900],
                                    );
                                  }
                                },
                              );
                            }
                          : null,
                      onDownload: () async {
                        final result = await vm.downloadAndOpenPDF(report);

                        if (result is Error) {
                          if (context.mounted) {
                            showSnackBar(
                              context: context,
                              text:
                                  vm.message ??
                                  "An unknown error occured. Please try again.",
                              color: Colors.red[900],
                            );
                          }
                        }
                      },
                    );
                  })
                else
                  NoFeatureScreen(screenFeature: Feature.report),
              ],
            ),
          ),
        ),
      ),
    );
  }
}