import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'hsp_add_details_screen.dart';
import 'hsp_detail_screen.dart';
import 'widgets/hsp_container.dart';
import '../viewmodels/hsp_modify_viewmodel.dart';
import '../viewmodels/hsp_view_viewmodel.dart';
import '../../../../config/constants/global_values.dart';
import '../../../../core/widgets/account_checker.dart';
import '../../../../core/widgets/add_button.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../../utils/data/results.dart';
import '../../../../utils/ui/animations_transitions.dart';
import '../../../../utils/ui/show_delete_confirmation_dialogue.dart';
import '../../../../utils/ui/show_snackbar.dart';

class HealthScreeningModifyViewScreen extends StatelessWidget {
  const HealthScreeningModifyViewScreen({super.key});

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final vmModify = context.watch<HealthScreeningModifyViewModel>();
    final vmData = context.watch<HealthScreeningViewModel>();

    return LoadingOverlay(
      isLoading: vmData.isLoading || vmModify.isLoading,
      loadingIndicator: vmData.isLoading ? false : true,
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
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Edit Health Packages',
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
        body: CustomScrollView(
          slivers: [
            // Header & Guidelines
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "  Our Current Package",
                        style: GoogleFonts.poppins(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF404040),
                        ),
                      ),
                      AddButton(
                        onTap: () {
                          Navigator.of(context).push(
                            transitionAnimation(
                              page: AuthWrappper(
                                accessRole: UserRole.admin,
                                child: const HealthScreeningAddDetailScreen(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Image Guidelines",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "• Size: 800 × 800 px\n"
                          "• Format: JPG or PNG\n"
                          "• Max file size: 5 MB",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFF616161),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    "  Current Packages",
                    style: GoogleFonts.poppins(
                      fontSize: 17.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF404040),
                    ),
                  ),
                  const SizedBox(height: 0),
                ]),
              ),
            ),

            // Packages Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final package = vmData.packages[index];

                  return HealthScreeningContainer(
                    package: package,
                    onTap: () {
                      Navigator.of(context).push(
                        transitionAnimation(
                          page: AuthWrappper(
                            accessRole: UserRole.admin,
                            child: HealthScreeningDetailViewScreen(
                              mode: ScreenRole.edit,
                              package: package,
                            ),
                          ),
                        ),
                      );
                    },
                    onDelete: () {
                      showDeleteConfirmationDialog(
                        context: context,
                        title: "Delete Health Screening Package",
                        message:
                            "Are you sure you want to delete ${package.name} and its details? This action cannot be undone.",
                        confirmButtonText: "Yes, Deactivate",
                        successTitle: "Health Screening Package Deleted!",
                        successMessage:
                            "${package.name}’s and its details has successfully been archived.",
                        onDelete: () async {
                          final result = await vmModify.deletePackage(package);

                          if (!context.mounted) return;

                          if (result is Error) {
                            showSnackBar(
                              context: context,
                              text:
                                  vmModify.message ??
                                  "An unknown error occured. Please try again.",
                              color: Colors.red[900],
                            );
                          }
                        },
                        whenDelete: () async {
                          final result = await vmData.load();

                          if (!context.mounted) return;

                          if (result is Error) {
                            showSnackBar(
                              context: context,
                              text:
                                  vmData.message ??
                                  "An unknown error occured. Please try again.",
                              color: Colors.red[900],
                            );
                          }
                        },
                      );
                    },
                  );
                }, childCount: vmData.packages.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.6,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}
