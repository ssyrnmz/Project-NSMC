// Info: Main prescription list screen for users (Current & History tabs).
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'presc_details_screen.dart';
import 'widgets/presc_management_box.dart';
import '../viewmodels/presc_view_viewmodel.dart';
import '../../domain/prescription.dart';
import '../../../../config/constants/global_values.dart';
import '../../../../core/widgets/find_item_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../../core/widgets/search_bar.dart';
import '../../../../core/widgets/no_feature_screen.dart';
import '../../../../utils/data/results.dart';
import '../../../../utils/ui/animations_transitions.dart';
import '../../../../utils/ui/show_snackbar.dart';

class PrescManagementScreen extends StatefulWidget {
  const PrescManagementScreen({super.key});

  @override
  State<PrescManagementScreen> createState() => _PrescManagementScreenState();
}

class _PrescManagementScreenState extends State<PrescManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  //▫️State initialization & disposal
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<PrescriptionViewModel>();
      final result = await vm.load(null);

      if (!mounted) return;

      if (result is Error) {
        showSnackBar(
          context: context,
          text: vm.message ?? "An unknown error occurred. Please try again.",
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
            title: Text(
              'Prescription',
              style: GoogleFonts.poppins(
                color: const Color(0xFF1E1E1E),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
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
                        vm.searchList.entries.where((e) =>
                            e.value.status == type),
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

          // 🔹 Prescription list or empty state
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
                title: DateFormat('dd MMMM yyyy').format(p.prescribedDate),
                subtitle: p.medications.isNotEmpty
                    ? p.medications.map((m) => m.name).join(', ')
                    : 'View prescription details',
                isAdmin: false,
                onTap: () {
                  Navigator.push(
                    context,
                    transitionAnimation(
                      page: PrescDetailsScreen(prescription: p),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
