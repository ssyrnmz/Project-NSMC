import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'widgets/bottom_navigation_bar.dart';
import 'widgets/service_boxes.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../authentication/data/account_session.dart';
import '../../appointment/domain/appointment.dart';
import '../../information/views/information_screen.dart';
import '../../profile/views/account_screen.dart';
import '../../../config/constants/global_values.dart';
import '../../../core/widgets/account_checker.dart';
import '../../../core/widgets/admin_dashboard.dart';
import '../../../core/widgets/user_dashboard.dart';
import '../../../core/widgets/loading_screen.dart';
import '../../../core/widgets/find_item_screen.dart';
import '../../../core/widgets/search_bar.dart';
import '../../../utils/ui/animations_transitions.dart';
import '../../../utils/ui/show_snackbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //▫️Variables:
  int _selectedIndex = 0; // Bottom navigation screen selector

  // Bottom navigation screen choices
  final List<Widget> _pages = [const InfoScreen(), const AccountScreen()];

  //▫️State initialization:
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vmInitial = context.read<HomeViewModel>();
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
    final vmHome = context.watch<HomeViewModel>();

    return LoadingOverlay(
      isLoading: vmHome.isLoading,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: _selectedIndex == 0
            ? PreferredSize(
                preferredSize: const Size.fromHeight(150), // Adjusted height
                child: Stack(
                  children: [
                    // Shadow layer behind the AppBar
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                    AppBar(
                      automaticallyImplyLeading: false,
                      elevation: 0,
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(20),
                        ),
                      ),
                      flexibleSpace: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(30),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFE8F7F0),
                              Color(0xFFE8F7F0), // Adds a hint of blue
                              Color(0xFFE8F7F0),
                            ],
                          ),
                          border: Border.all(
                            color: Color(0xFFE0F2E7), // Very light border
                            width: 1,
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 12,
                              left: 20,
                              right: 20,
                              bottom: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top row with logo and greeting
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // Logo without container
                                    Image.asset(
                                      'assets/images/NSMC_LOGO_BLUR.png',
                                      fit: BoxFit.contain,
                                      height: 48,
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Normah Medical Specialist Centre',
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF5A6C8A),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          (session.role == UserRole.admin)
                                              ? 'Hello, Admin'
                                              : vmHome.getTimeBasedGreeting(),
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF2D3748),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // Search bar section
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: SearchBarWidget(
                                    onTapped: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FindItemScreen(
                                          hintText: 'Search for our services',
                                          items: vmHome.searchList,
                                          leadingIcon: Icons.medical_services,
                                          circleColor: Colors.green,
                                          onItemSelected: (value) {
                                            Navigator.pop(context);

                                            Navigator.of(context).push(
                                              transitionAnimation(
                                                page: AuthWrappper(
                                                  accessRole: session.role,
                                                  child: value,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    hintText: 'Search for our services',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : null,

        bottomNavigationBar: BottomNavBar(
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),

        body: _selectedIndex == 0
            ? _buildHomeContent(session.role, vmHome.pendingAppointments)
            : _pages[_selectedIndex - 1],
      ),
    );
  }

  //▫️Helper Widget:
  // Main content (Screen body section)
  Widget _buildHomeContent(UserRole role, List<Appointment> appointments) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            (role == UserRole.admin)
                ? AdminDashboardBox(appointments: appointments)
                : const UserDashboardBox(),

            SizedBox(height: (role == UserRole.admin) ? 19 : 11),

            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Text(
                (role == UserRole.admin)
                    ? "   Our services"
                    : "   Discover our services",
                style: GoogleFonts.poppins(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF404040),
                ),
              ),
            ),

            ServicesBox(role: role),
          ],
        ),
      ),
    );
  }
}
