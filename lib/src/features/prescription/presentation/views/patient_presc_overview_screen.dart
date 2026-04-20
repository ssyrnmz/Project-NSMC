// Info: Admin screen to view and manage a specific patient's prescriptions.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'presc_details_screen.dart';
import 'presc_modify_screen.dart';
import 'widgets/presc_management_box.dart';
import '../viewmodels/presc_view_viewmodel.dart';
import '../viewmodels/presc_modify_viewmodel.dart';
import '../../domain/prescription.dart';
import '../../../../config/constants/global_values.dart';
import '../../../../core/widgets/add_button.dart';
import '../../../../core/widgets/find_item_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../../core/widgets/search_bar.dart';
import '../../../../core/widgets/no_feature_screen.dart';
import '../../../../utils/data/results.dart';
import '../../../../utils/ui/animations_transitions.dart';
import '../../../../utils/ui/show_snackbar.dart';
import '../../../../utils/ui/show_delete_confirmation_dialogue.dart';

class PatientPrescOverviewScreen extends StatefulWidget {
  const PatientPrescOverviewScreen({
    super.key,
    required this.userId,
    required this.patientName,
  });

  final String userId;
  final String patientName;

  @override
  State<PatientPrescOverviewScreen> createState() =>
      _PatientPrescOverviewScreenState();
}

class _PatientPrescOverviewScreenState
    extends State<PatientPrescOverviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  //▫️State initialization & disposal
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<PrescriptionViewModel>();
      final result = await vm.load(widget.userId);

      if (!mounted) return;

      if (result is Error) {
        showSnackBar(
          context: context,
          text: vm.message ?? 'An unknown error occurred. Please try again.',
          color: Colors.red[900],
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  //▫️Delete handler
  void _handleDelete(BuildContext context, Prescription prescription) {
    showDeleteConfirmationDialog(
      context: context,
      title: 'Delete Prescription',
      message:
          'Are you sure you want to delete this prescription? This action cannot be undone.',
      confirmButtonText: 'Yes, Delete',
      onDelete: () async {
        final vmModify = context.read<PrescriptionModifyViewModel>();
        final vmView = context.read<PrescriptionViewModel>();

        final result =
            await vmModify.deletePrescription(prescription.id);

        if (!mounted) return;

        if (result is Error) {
          showSnackBar(
            context: context,
            text: vmModify.message ??
                'Failed to delete. Please try again.',
            color: Colors.red[900],
          );
        } else {
          await vmView.load(widget.userId);
          if (!mounted) return;
          showSnackBar(
            context: context,
            text: 'Prescription deleted successfully.',
            color: Colors.green[800],
          );
        }
      },
    );
  }

  //▫️Main UI
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PrescriptionViewModel>();

    return LoadingOverlay(
        isLoading: vm.isLoading,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                  Icons.arrow_back_ios_new, color: Color(0xFF4D7C4A)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${widget.patientName}\'s Prescriptions',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1E1E1E),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AddButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      transitionAnimation(
                        page: PrescModifyScreen(userId: widget.userId),
                      ),
                    );
                  },
                ),
              ],
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF4D7C4A),
              indicatorWeight: 3,
              labelColor: const Color(0xFF4D7C4A),
              unselectedLabelColor: Colors.grey,
              labelStyle: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              tabs: const [
                Tab(text: 'Current'),
                Tab(text: 'History'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTabContent(context, vm, 'current'),
              _buildTabContent(context, vm, 'history'),
            ],
          ),
        ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    PrescriptionViewModel vm,
    String type,
  ) {
    final prescriptions = type == 'current'
        ? vm.currentPrescriptions
        : vm.historyPrescriptions;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),

          // 🔹 Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SearchBarWidget(
              onTapped: () {
                Navigator.push(
                  context,
                  transitionAnimation(
                    page: FindItemScreen(
                      hintText:
                          'Search for ${type == 'current' ? 'current' : 'history'} prescription',
                      items: Map.fromEntries(
                        vm.searchList.entries.where(
                            (e) => e.value.status == type),
                      ),
                      onItemSelected: (item) {
                        if (item is Prescription) vm.searchPicked(item);
                      },
                    ),
                  ),
                );
              },
              hintText:
                  'Search for ${type == 'current' ? 'current' : 'history'} prescription',
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 35, vertical: 9),
            child: Divider(
              color: const Color.fromARGB(255, 232, 232, 232),
              thickness: 1.0,
            ),
          ),

          // 🔹 Prescription list
          if (prescriptions.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 60),
              child: NoFeatureScreen(
                screenFeature: Feature.prescription,
              ),
            )
          else
            ...prescriptions.map(
              (p) => PrescManagementBox(
                title: DateFormat('dd MMMM yyyy')
                    .format(p.prescribedDate),
                subtitle: p.medications.isNotEmpty
                    ? p.medications.map((m) => m.name).join(', ')
                    : 'View prescription details',
                isAdmin: true,
                onTap: () {
                  Navigator.push(
                    context,
                    transitionAnimation(
                      page: PrescDetailsScreen(prescription: p),
                    ),
                  );
                },
                onDelete: () => _handleDelete(context, p),
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
