import 'package:flutter/material.dart';

class HomeBottomNavigationBar extends StatefulWidget {
  final Function(int) onTabChange; // Callback to notify parent
  final int selectedIndex;

  const HomeBottomNavigationBar({
    super.key,
    required this.onTabChange,
    required this.selectedIndex,
  });

  @override
  State<HomeBottomNavigationBar> createState() => _MyBottomNavBarState();
}

class _MyBottomNavBarState extends State<HomeBottomNavigationBar> {
  // Define tab icons and labels
  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home'},
    {
      'icon': Icons.inbox_outlined,
      'activeIcon': Icons.inbox_rounded,
      'label': 'Inbox',
    },
    //{'icon': Icons.mail_outline, 'activeIcon': Icons.mail, 'label': 'Messages'},
    {
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
      'label': 'Account',
    },
  ];
  // Colors
  final Color _activeColor = const Color(0xFF5FAF9E);
  final Color _inactiveColor = Colors.grey.shade500;

  // Function to build each nav item
  Widget _buildNavItem(int index) {
    final bool isSelected = index == widget.selectedIndex;

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
              Icon(
                isSelected
                    ? _navItems[index]['activeIcon'] as IconData
                    : _navItems[index]['icon'] as IconData,
                size: 26,
                color: isSelected ? _activeColor : _inactiveColor,
              ),
              const SizedBox(height: 4),
              Text(
                _navItems[index]['label'] as String,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
            return _buildNavItem(index);
          }),
        ),
      ),
    );
  }
}
