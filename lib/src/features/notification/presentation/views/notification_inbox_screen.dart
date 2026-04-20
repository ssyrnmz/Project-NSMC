// Info: Patient inbox screen — shows all in-app notifications with date/time,
// type-specific icons, and taps that navigate to the relevant feature.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../viewmodels/notification_viewmodel.dart';
import '../../domain/app_notification.dart';

class NotificationInboxScreen extends StatefulWidget {
  const NotificationInboxScreen({super.key});

  @override
  State<NotificationInboxScreen> createState() =>
      _NotificationInboxScreenState();
}

class _NotificationInboxScreenState extends State<NotificationInboxScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().load();
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Format the notification timestamp into a human-readable string.
  /// Shows "Today, HH:mm", "Yesterday, HH:mm", or "dd MMM yyyy, HH:mm".
  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notifDay = DateTime(local.year, local.month, local.day);
    final timeStr = DateFormat('HH:mm').format(local);

    if (notifDay == today) return 'Today, $timeStr';
    if (notifDay == yesterday) return 'Yesterday, $timeStr';
    return '${DateFormat('dd MMM yyyy').format(local)}, $timeStr';
  }

  /// Map a notification type to a display-friendly label.
  String _typeLabel(String type) {
    switch (type) {
      case 'medical_record':
        return 'Medical Report';
      case 'appointment_approved':
        return 'Appointment';
      case 'appointment_rejected':
        return 'Appointment';
      case 'appointment_rescheduled':
        return 'Appointment';
      case 'health_package':
        return 'Health Package';
      case 'prescription':
        return 'Prescription';
      default:
        return 'Notification';
    }
  }

  /// Map a notification type to an icon.
  IconData _typeIcon(String type) {
    switch (type) {
      case 'medical_record':
        return Icons.description_outlined;
      case 'appointment_approved':
        return Icons.event_available_outlined;
      case 'appointment_rejected':
        return Icons.event_busy_outlined;
      case 'appointment_rescheduled':
        return Icons.update_outlined;
      case 'health_package':
        return Icons.health_and_safety_outlined;
      case 'prescription':
        return Icons.medication_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  /// Map a notification type to a theme colour.
  Color _typeColor(String type) {
    switch (type) {
      case 'medical_record':
        return const Color(0xFF4D7C4A); // green
      case 'appointment_approved':
        return const Color(0xFF1976D2); // blue
      case 'appointment_rejected':
        return const Color(0xFFD32F2F); // red
      case 'appointment_rescheduled':
        return const Color(0xFFF57C00); // orange
      case 'health_package':
        return const Color(0xFF7B1FA2); // purple
      case 'prescription':
        return const Color(0xFF00796B); // teal
      default:
        return const Color(0xFF607D8B); // grey
    }
  }

  // ── Main UI ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationViewModel>();

    return Scaffold(
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
          'Inbox',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1E1E1E),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (vm.notifications.isNotEmpty)
            TextButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(
                      'Clear all notifications?',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    content: Text(
                      'This will dismiss all notifications from your inbox.',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          'Clear All',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  vm.dismissAll();
                }
              },
              child: Text(
                'Clear All',
                style: GoogleFonts.poppins(
                  color: Colors.red[400],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE6E6E6), height: 1),
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4D7C4A)))
          : vm.notifications.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  color: const Color(0xFF4D7C4A),
                  onRefresh: () => vm.load(),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: vm.notifications.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      indent: 72,
                      endIndent: 16,
                      color: Color(0xFFF0F0F0),
                    ),
                    itemBuilder: (context, index) {
                      final notif = vm.notifications[index];
                      return _NotificationTile(
                        notif: notif,
                        icon: _typeIcon(notif.type),
                        color: _typeColor(notif.type),
                        label: _typeLabel(notif.type),
                        dateStr: _formatDate(notif.createdAt),
                        onTap: () => _handleTap(context, notif, vm),
                        onDismiss: () => vm.dismiss(notif),
                      );
                    },
                  ),
                ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Your inbox is empty',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Notifications about your appointments,\nmedical reports and more will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[400],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Tap handler ────────────────────────────────────────────────────────────
  // Mark as read then navigate to the appropriate screen.
  // Add your own route names / Navigator.push calls to match your app's routing.
  void _handleTap(
    BuildContext context,
    AppNotification notif,
    NotificationViewModel vm,
  ) {
    vm.markRead(notif);

    switch (notif.type) {
      case 'medical_record':
        // Navigate to the patient's medical record screen.
        // Replace with your actual route/page if using named routes.
        Navigator.pushNamed(context, '/medicalRecords');
        break;

      case 'appointment_approved':
      case 'appointment_rejected':
      case 'appointment_rescheduled':
        // Navigate to the patient's appointments list.
        Navigator.pushNamed(context, '/appointments');
        break;

      case 'health_package':
        // Navigate to the health packages view screen.
        Navigator.pushNamed(context, '/healthPackages');
        break;

      case 'prescription':
        // Navigate to the patient's prescription list.
        Navigator.pushNamed(context, '/prescriptions');
        break;

      default:
        // Generic — do nothing extra beyond marking read.
        break;
    }
  }
}

// ── Tile widget ───────────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notif,
    required this.icon,
    required this.color,
    required this.label,
    required this.dateStr,
    required this.onTap,
    required this.onDismiss,
  });

  final AppNotification notif;
  final IconData icon;
  final Color color;
  final String label;
  final String dateStr;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notif.isRead;

    return Dismissible(
      key: ValueKey(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red[50],
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) => onDismiss(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: isUnread
              ? color.withOpacity(0.04)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon badge ──────────────────────────────────────────────
              Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  if (isUnread)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 12),

              // ── Text content ────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type chip + date on same row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            label,
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                        Text(
                          dateStr,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // Title
                    Text(
                      notif.title,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight:
                            isUnread ? FontWeight.w600 : FontWeight.w500,
                        color: const Color(0xFF1E1E1E),
                      ),
                    ),

                    const SizedBox(height: 3),

                    // Message
                    Text(
                      notif.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
