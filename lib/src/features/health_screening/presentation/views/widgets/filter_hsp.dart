import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterPackageScreen extends StatefulWidget {
  const FilterPackageScreen({
    super.key,
    required this.categories, // Dynamic categories from database
    this.initialSort,
    this.initialCategory,
  });

  final List<String> categories;
  final String? initialSort;
  final String? initialCategory;

  @override
  State<FilterPackageScreen> createState() => _FilterPackageScreenState();
}

class _FilterPackageScreenState extends State<FilterPackageScreen> {
  String? selectedSort;
  String? selectedCategory;

  final List<String> sortOptions = [
    'Price: Low to High',
    'Price: High to Low',
  ];

  @override
  void initState() {
    super.initState();
    selectedSort = widget.initialSort;
    selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFF4CAF50);
    const Color softGreen = Color(0xFFE8F5E9);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFf9fafb),
        surfaceTintColor: const Color.fromARGB(255, 200, 200, 200),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
              Icons.arrow_back_ios_new, color: Color(0xFF4D7C4A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Filter Packages',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1E1E1E),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Reset button
          TextButton(
            onPressed: () {
              setState(() {
                selectedSort = null;
                selectedCategory = null;
              });
            },
            child: Text(
              'Reset',
              style: GoogleFonts.poppins(
                color: Colors.red.shade400,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child:
              Container(color: const Color(0xFFE6E6E6), height: 1),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 25, 25, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Sort section ──────────────────────────
              Text(
                ' Sort by',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: sortOptions.map((option) {
                  final isSelected = selectedSort == option;
                  return _buildChip(
                    label: option,
                    isSelected: isSelected,
                    accentColor: accentColor,
                    softGreen: softGreen,
                    onSelected: () => setState(() =>
                        selectedSort = isSelected ? null : option),
                  );
                }).toList(),
              ),

              const SizedBox(height: 35),

              // ── Category section ──────────────────────
              Text(
                ' Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 15),

              // Show message if no categories loaded from DB yet
              if (widget.categories.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFFFFE082), width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 16, color: Color(0xFFFF8F00)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No categories found. Add the package_category column to the database first.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF795548),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    // "All" chip to clear category filter
                    _buildChip(
                      label: 'All',
                      isSelected: selectedCategory == null,
                      accentColor: accentColor,
                      softGreen: softGreen,
                      onSelected: () =>
                          setState(() => selectedCategory = null),
                    ),
                    ...widget.categories.map((cat) {
                      final isSelected = selectedCategory == cat;
                      return _buildChip(
                        label: cat,
                        isSelected: isSelected,
                        accentColor: accentColor,
                        softGreen: softGreen,
                        onSelected: () => setState(() =>
                            selectedCategory =
                                isSelected ? null : cat),
                      );
                    }),
                  ],
                ),

              const Spacer(),

              // ── Apply button ──────────────────────────
              SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6FBF73),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context, {
                        'sort': selectedSort,
                        'category': selectedCategory,
                      });
                    },
                    child: Text(
                      'Apply Filters',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required Color accentColor,
    required Color softGreen,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      backgroundColor: Colors.white,
      selectedColor: softGreen,
      showCheckmark: false,
      labelStyle: GoogleFonts.poppins(
        color: isSelected ? accentColor : Colors.black,
        fontWeight:
            isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.grey[300]!,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      avatar: isSelected
          ? CircleAvatar(
              radius: 12,
              backgroundColor: accentColor,
              child: const Icon(Icons.check,
                  color: Colors.white, size: 16),
            )
          : null,
      elevation: 0,
      shadowColor: Colors.transparent,
      pressElevation: 0,
      onSelected: (_) => onSelected(),
    );
  }
}