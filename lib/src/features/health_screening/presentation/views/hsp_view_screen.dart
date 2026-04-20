import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/hsp_container.dart';
import 'hsp_detail_screen.dart';
import 'hsp_edit_carousel_screen.dart';
import 'hsp_modify_screen.dart';
import 'widgets/filter_hsp.dart';
import 'widgets/image_carousel.dart';
import 'widgets/manage_hsp_button.dart';
import '../viewmodels/hsp_view_viewmodel.dart';
import '../../../authentication/data/account_session.dart';
import '../../../../config/constants/global_values.dart';
import '../../../../core/widgets/account_checker.dart';
import '../../../../core/widgets/find_item_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../../core/widgets/search_bar.dart';
import '../../../../core/widgets/no_feature_screen.dart';
import '../../../../utils/ui/animations_transitions.dart';
import '../../../../utils/ui/show_snackbar.dart';

class HealthScreeningViewScreen extends StatefulWidget {
  const HealthScreeningViewScreen({super.key});

  @override
  State<HealthScreeningViewScreen> createState() =>
      _HealthScreeningViewScreenState();
}

class _HealthScreeningViewScreenState extends State<HealthScreeningViewScreen> {
  //▫️State initialization:
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vmInitial = context.read<HealthScreeningViewModel>();
      final result = await vmInitial.load();

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
    final vm = context.watch<HealthScreeningViewModel>();

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
          title: (session.role == UserRole.admin && session.isFullAdmin)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Packages',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF1E1E1E),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 40),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: ManageHealthButton(
                          // Button to navigate to edit carousel and package screen
                          onCarouselImage: () {
                            Navigator.of(context).push(
                              transitionAnimation(
                                page: AuthWrappper(
                                  accessRole: UserRole.admin,
                                  child: EditCarouselImageScreen(),
                                ),
                              ),
                            );
                          },
                          onHealthPackage: () {
                            Navigator.of(context).push(
                              transitionAnimation(
                                page: AuthWrappper(
                                  accessRole: UserRole.admin,
                                  child: HealthScreeningModifyViewScreen(),
                                ),
                                route: const RouteSettings(
                                  name: '/packageModifyList',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : Text(
                  'Health Screenings',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15.0),

              // Search bar + filter
              Padding(
                padding: const EdgeInsets.only(left: 6.0, right: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: SearchBarWidget(
                        hintText: 'Search for packages',
                        onTapped: () {
                          Navigator.of(context).push(
                            transitionAnimation(
                              page: FindItemScreen(
                                hintText: 'Search for a package',
                                items: vm.searchList,
                                leadingIcon: Icons.medical_services,
                                onItemSelected: (value) {
                                  Navigator.pop(
                                    context,
                                  ); // Close the search screen

                                  Navigator.of(context).push(
                                    transitionAnimation(
                                      page: AuthWrappper(
                                        accessRole: session.role,
                                        child: HealthScreeningDetailViewScreen(
                                          mode: ScreenRole.view,
                                          package: value,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 0),
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.of(context).push(
                          transitionAnimation(
                            page: FilterPackageScreen(
                              categories: vm.categories,
                            ),
                          ),
                        );

                        if (result != null) {
                          final String? selectedSort = result['sort'];
                          final String? selectedCategory =
                              result['category'];
                          vm.filterOut(selectedSort,
                              category: selectedCategory);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF7CB342).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.filter_alt_rounded,
                            color: Color(0xFF7CB342),
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Recommended title
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  (session.role == UserRole.admin)
                      ? "  Our Carousel Images"
                      : "  Recommended for you",
                  style: GoogleFonts.poppins(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF404040),
                  ),
                ),
              ),

              const SizedBox(height: 28.0),

              // Carousel
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: ImageCarousel(autoPlay: true, images: vm.images),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 9),
                child: Divider(
                  color: const Color.fromARGB(255, 232, 232, 232),
                  thickness: 1.0,
                ),
              ),

              const SizedBox(height: 10),

              // Discover more section
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: Text(
                  (session.role == UserRole.admin)
                      ? "  Our Health Packages"
                      : "  Discover more",
                  style: GoogleFonts.poppins(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF404040),
                  ),
                ),
              ),

              const SizedBox(height: 28.0),

              // Grid of packages
              (vm.filteredPackages.isNotEmpty)
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double totalWidth = constraints.maxWidth;
                          const int crossAxisCount = 2;
                          const double spacing = 12;
                          final double totalSpacing =
                              spacing * (crossAxisCount - 1);
                          final double itemWidth =
                              (totalWidth - totalSpacing) / crossAxisCount;
                          const double desiredItemHeight = 325;
                          final double aspectRatio =
                              itemWidth / desiredItemHeight;

                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: spacing,
                            mainAxisSpacing: spacing,
                            childAspectRatio: aspectRatio,
                            children: vm.filteredPackages.map((package) {
                              return HealthScreeningContainer(
                                package: package,
                                onTap: () {
                                  Navigator.of(context).push(
                                    transitionAnimation(
                                      page: AuthWrappper(
                                        accessRole: session.role,
                                        child: HealthScreeningDetailViewScreen(
                                          mode: ScreenRole.view,
                                          package: package,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                    )
                  : NoFeatureScreen(screenFeature: Feature.packages),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}