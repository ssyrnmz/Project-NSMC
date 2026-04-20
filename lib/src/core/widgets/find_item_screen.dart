import 'package:flutter/material.dart';

import 'non_navigate_searchBar.dart';
import 'search_dropdown.dart';
import 'patient_details_illustration.dart';

class FindItemScreen extends StatefulWidget {
  final String hintText; // Placeholder for search bar
  final Map<String, dynamic> items; // List to search from
  final Function(dynamic) onItemSelected; // Callback when user taps
  final IconData leadingIcon; // Circular icon
  final Color iconColor;
  final Color circleColor;

  const FindItemScreen({
    super.key,
    required this.hintText,
    required this.items,
    required this.onItemSelected,
    this.leadingIcon = Icons.person,
    this.iconColor = Colors.white,
    this.circleColor = Colors.green,
  });

  @override
  State<FindItemScreen> createState() => _FindItemScreenState();
}

class _FindItemScreenState extends State<FindItemScreen> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode(); // Focus node for keyboard
  bool showList = false;
  late Map<String, dynamic> filtered;

  @override
  void initState() {
    super.initState();
    filtered = widget.items;

    // Automatically focus and show keyboard after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(searchFocusNode);
      //setState(() => showList = true); // Show dropdown immediately
    });
  }

  void filter(String query) {
    final Map<String, dynamic> newFiltered = {};
    if (query.isEmpty) {
      newFiltered.addAll(widget.items);
      filtered = newFiltered;
    } else {
      newFiltered.addEntries(
        widget.items.entries.where(
          (item) => item.key.toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }
    setState(() {
      filtered = newFiltered;
      showList = true;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose(); // Dispose focus node
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Hide keyboard if tapping outside
        setState(() => showList = false);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFf9fafb),
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 80,
          elevation: 0,
          centerTitle: true,
          //leading icon
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF4D7C4A),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: NonNavigateSearchBarWidget(
            hintText: widget.hintText,
            controller: searchController,
            focusNode: searchFocusNode, // Pass focus node
            onTap: () => setState(() => showList = true),
            onChanged: filter,
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: Color(0xFFE6E6E6)),
          ),
        ),
        body: Stack(
          children: [
            // Illustration behind dropdown
            const Center(child: PatientDetailsIllust()),
            // Dropdown list appears on top
            if (showList)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SearchDropdown(
                    items: filtered,
                    leadingIcon: widget.leadingIcon,
                    iconColor: widget.iconColor,
                    circleColor: widget.circleColor,
                    onItemTap: (value) {
                      widget.onItemSelected(value);
                      setState(() => showList = false);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
