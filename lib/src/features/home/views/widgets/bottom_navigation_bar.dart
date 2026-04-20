import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../home/viewmodels/home_viewmodel.dart';
import '../../../notification/presentation/viewmodels/notification_viewmodel.dart'; // NEW

class BottomNavBar extends StatefulWidget {
  final Function(int) onTabChange;
  final int selectedIndex;

  const BottomNavBar({
    super.key,
    required this.onTabChange,
    required this.selectedIndex,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home'},
    {
      'icon': Icons.inbox_outlined,
      'activeIcon': Icons.inbox_rounded,
      'label': 'Inbox',
    },
    {
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
      'label': 'Account',
    },
  ];

  final Color _activeColor = const Color(0xFF5FAF9E);
  final Color _inactiveColor = Colors.grey.shade500;

  Widget _buildNavItem(int index, int unreadCount) {
    final bool isSelected = index == widget.selectedIndex;
    final bool isInbox = index == 1;

    return Expanded(
      child: InkWell(
        onTap: () => widget.onTabChange(index),
        borderRadius: BorderRadius.circular(10.0),
        splashColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔴 Badge on inbox icon
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isSelected
                        ? _navItems[index]['activeIcon'] as IconData
                        : _navItems[index]['icon'] as IconData,
                    size: 26,
                    color: isSelected ? _activeColor : _inactiveColor,
                  ),
                  if (isInbox && unreadCount > 0)
                    Positioned(
                      top: -4,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE53935),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _navItems[index]['label'] as String,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? _activeColor : _inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vmHome = context.watch<HomeViewModel>();
    final vmNotif = context.watch<NotificationViewModel>(); // NEW

    // Total badge = unread health packages + unread medical record notifications
    final int unreadCount = vmHome.unreadCount + vmNotif.unreadCount; // UPDATED

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (index) {
            return _buildNavItem(index, unreadCount);
          }),
        ),
      ),
    );
  }
}
