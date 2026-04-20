import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchDropdown extends StatelessWidget {
  final Map<String, dynamic> items;
  final Function(dynamic) onItemTap;

  final IconData leadingIcon;
  final Color iconColor;
  final Color circleColor;

  const SearchDropdown({
    super.key,
    required this.items,
    required this.onItemTap,
    this.leadingIcon = Icons.person,
    this.iconColor = Colors.white,
    this.circleColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasResults = items.isNotEmpty;
    final List<String> keys = items.keys.toList();
    final List values = items.values.toList();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          // ⭐ If no results → height = one item (58–60px)
          height: hasResults ? null : 60,

          constraints: hasResults
              ? BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.83,
                )
              : null,

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),

          child: hasResults
              ? ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: const Color(0xFFE6E5E5), thickness: 0.5),
                  itemBuilder: (context, index) {
                    final searchName = keys[index];
                    final searchValue = values[index];

                    return InkWell(
                      hoverColor: Colors.grey.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => onItemTap(searchValue),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: circleColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                leadingIcon,
                                color: iconColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                searchName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: Color(0xFFB0B0B0),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              // ⭐ No results view (same height as 1 item)
              : Center(
                  child: Text(
                    "No results found",
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
