import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'widgets/information_preview_tile.dart';
import 'information_details_screen.dart';
import '../../authentication/data/account_session.dart';
import '../../home/viewmodels/home_viewmodel.dart';
import '../../notification/domain/app_notification.dart';
import '../../notification/presentation/viewmodels/notification_viewmodel.dart';
import '../../medical_record/presentation/views/mr_view_screen.dart';
import '../../appointment/presentation/views/apt_tracking_screen.dart';
import '../../appointment/presentation/views/apt_requested_screen.dart';
import '../../../config/constants/global_values.dart';
import '../../../core/widgets/account_checker.dart';
import '../../../core/widgets/no_feature_screen.dart';
import '../../../utils/ui/animations_transitions.dart';
import '../../../utils/ui/display_formatters.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().load();
    });
  }

  // Returns icon, color and bg color based on notification type
  ({IconData icon, Color color, Color bg}) _notifStyle(String type) {
    switch (type) {
      case 'appointment_new_request':
        return (
          icon: Icons.calendar_today_rounded,
          color: Colors.white,
          bg: const Color(0xFF7B8FD4),
        );
      case 'appointment_approved':
        return (
          icon: Icons.check_circle_rounded,
          color: Colors.white,
          bg: const Color(0xFF4D7C4A),
        );
      case 'appointment_confirmed':
        return (
          icon: Icons.how_to_reg_rounded,
          color: Colors.white,
          bg: const Color(0xFF2196F3),
        );
      case 'medical_record':
        return (
          icon: Icons.description_rounded,
          color: Colors.white,
          bg: const Color(0xFF4D7C4A),
        );
      default:
        return (
          icon: Icons.notifications_rounded,
          color: Colors.white,
          bg: const Color(0xFFB6D8F9),
        );
    }
  }

  // Navigate based on notification type
  void _handleTap(
      BuildContext context, AppNotification notif, NotificationViewModel vm, UserRole role) async {
    await vm.markRead(notif);
    if (!context.mounted) return;

    switch (notif.type) {
      case 'appointment_new_request':
      case 'appointment_confirmed':
        // Admin → go to appointment requests
        Navigator.of(context).push(transitionAnimation(
          page: AuthWrappper(
            accessRole: UserRole.admin,
            child: const AppointmentRequestedScreen(),
          ),
        ));
        break;
      case 'appointment_approved':
        // Patient → go to appointment tracking
        Navigator.of(context).push(transitionAnimation(
          page: AuthWrappper(
            accessRole: UserRole.user,
            child: const AppointmentTrackingViewScreen(),
          ),
        ));
        break;
      case 'medical_record':
        // Patient → go to medical records
        Navigator.of(context).push(transitionAnimation(
          page: AuthWrappper(
            accessRole: UserRole.user,
            child: const MedicalRecordViewScreen(),
          ),
        ));
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AccountSession>();
    final vm = context.watch<HomeViewModel>();
    final notifVm = context.watch<NotificationViewModel>();

    final visiblePackages = vm.visiblePackages;
    final notifications = notifVm.notifications;

    final totalUnread = vm.unreadCount + notifVm.unreadCount;
    final hasContent = visiblePackages.isNotEmpty || notifications.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        title: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Row(
            children: [
              Text(
                'Inbox',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1E1E1E),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (totalUnread > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E72E8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalUnread',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (hasContent)
            TextButton(
              onPressed: () {
                vm.dismissAll();
                notifVm.dismissAll();
              },
              child: Text(
                'Clear All',
                style: GoogleFonts.poppins(
                  color: Colors.red.shade400,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE6E6E6), height: 1),
        ),
      ),

      body: notifVm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: hasContent
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C63FF),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Latest',
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            children: [

                              // ── In-app notifications (appointments + medical records) ──
                              ...notifications.map((notif) {
                                final style = _notifStyle(notif.type);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: InfoPreviewTile(
                                    title: notif.title,
                                    message: notif.message,
                                    isRead: notif.isRead,
                                    date: notif.createdAt,
                                    icon: style.icon,
                                    iconColor: style.color,
                                    iconBgColor: style.bg,
                                    onDelete: () => notifVm.dismiss(notif),
                                    onTap: () => _handleTap(
                                        context, notif, notifVm, session.role),
                                  ),
                                );
                              }),

                              // ── Health Package Notifications ────────────────
                              ...visiblePackages.map((package) {
                                final isRead = vm.isRead(package.name);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: InfoPreviewTile(
                                    title: 'New Health Package Available',
                                    message: DisplayFormat()
                                        .infoMessage(package.name),
                                    isRead: isRead,
                                    date: package.updatedAt,
                                    icon: Icons.health_and_safety_rounded,
                                    iconColor: Colors.white,
                                    iconBgColor: const Color(0xFFB6D8F9),
                                    onDelete: () => vm.dismiss(package.name),
                                    onTap: () {
                                      vm.markRead(package.name);
                                      Navigator.of(context).push(
                                        transitionAnimation(
                                          page: AuthWrappper(
                                            accessRole: session.role,
                                            child: InfoDetailsScreen(
                                                package: package),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    )
                  : NoFeatureScreen(screenFeature: Feature.information),
            ),
    );
  }
}