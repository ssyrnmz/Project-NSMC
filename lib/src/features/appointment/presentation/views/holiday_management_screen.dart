import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:provider/provider.dart';

import '../../data/public_holiday_repository.dart';
import '../../domain/public_holiday.dart';
import '../../../../utils/data/results.dart';
import '../../../../utils/ui/show_snackbar.dart';

class HolidayManagementScreen extends StatefulWidget {
  const HolidayManagementScreen({super.key});

  @override
  State<HolidayManagementScreen> createState() =>
      _HolidayManagementScreenState();
}

class _HolidayManagementScreenState extends State<HolidayManagementScreen> {
  final _nameCtrl = TextEditingController();
  DateTime? _selectedDate;
  bool _isSaving = false;
  List<PublicHoliday> _holidays = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHolidays());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHolidays() async {
    setState(() {
      _isLoading = true;
    });
    final repo = context.read<PublicHolidayRepository>();
    final result = await repo.getHolidays();
    if (!mounted) return;
    if (result is Ok<List<PublicHoliday>>) {
      setState(() {
        _holidays = result.value;
        _holidays.sort((a, b) => a.date.compareTo(b.date));
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      showSnackBar(
        context: context,
        text: 'Could not load holidays. Check your connection.',
        color: Colors.orange[900],
      );
    }
  }

  Future<void> _addHoliday() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _selectedDate == null) {
      showSnackBar(
        context: context,
        text: 'Please enter a holiday name and pick a date.',
        color: Colors.red[900],
      );
      return;
    }

    setState(() => _isSaving = true);

    final repo = context.read<PublicHolidayRepository>();
    final holiday = PublicHoliday(
      id: 0,
      name: name,
      date: _selectedDate!,
      updatedAt: DateTime.now(),
    );

    final result = await repo.addHoliday(holiday);
    if (!mounted) return;

    setState(() => _isSaving = false);

    if (result is Ok) {
      _nameCtrl.clear();
      setState(() => _selectedDate = null);
      showSnackBar(
        context: context,
        text: 'Holiday added successfully.',
        color: const Color(0xFF4D7C4A),
      );
      await _loadHolidays();
    } else {
      showSnackBar(
        context: context,
        text: 'Failed to add holiday. Please try again.',
        color: Colors.red[900],
      );
    }
  }

  Future<void> _deleteHoliday(PublicHoliday item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove Holiday',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(
          'Remove "${item.name}" (${_formatDate(item.date)}) from the holiday list?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Remove',
                style: GoogleFonts.poppins(color: Colors.red[700])),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final repo = context.read<PublicHolidayRepository>();
    final result = await repo.deleteHoliday(item.id);
    if (!mounted) return;

    if (result is Ok) {
      showSnackBar(
        context: context,
        text: 'Holiday removed.',
        color: const Color(0xFF4D7C4A),
      );
      await _loadHolidays();
    } else {
      showSnackBar(
        context: context,
        text: 'Failed to remove holiday. Please try again.',
        color: Colors.red[900],
      );
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showRoundedDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      borderRadius: 16,
      height: 290,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF629E5C),
          onPrimary: Colors.white,
          onSurface: Colors.black87,
        ),
        dialogBackgroundColor: Colors.white,
      ),
      styleDatePicker: MaterialRoundedDatePickerStyle(
        textStyleMonthYearHeader: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Color(0xFF629E5C),
        ),
        textStyleButtonPositive: const TextStyle(
          color: Color(0xFF629E5C),
          fontWeight: FontWeight.w600,
        ),
        textStyleButtonNegative: const TextStyle(color: Color(0xFF9C9C9C)),
        decorationDateSelected: const BoxDecoration(
          color: Color(0xFF629E5C),
          shape: BoxShape.circle,
        ),
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFf7f7f7),
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF4D7C4A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage Public Holidays',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E1E1E),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE6E6E6), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Add holiday form ──────────────────────────
            Text(
              'Add New Holiday',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAF8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name field
                  Text('Holiday Name',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.black87)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: _inputDeco(hint: 'e.g. National Day'),
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  const SizedBox(height: 14),

                  // Date picker
                  Text('Date',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.black87)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xffefefef), width: 2),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: Color(0xFF8FBB8C), size: 18),
                          const SizedBox(width: 10),
                          Text(
                            _selectedDate == null
                                ? 'Pick a date'
                                : _formatDate(_selectedDate!),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: _selectedDate == null
                                  ? Colors.grey[500]
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _addHoliday,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.add_circle_outline, size: 18),
                      label: Text(
                        _isSaving ? 'Saving…' : 'Add Holiday',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4D7C4A),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            const Divider(thickness: 0.6),
            const SizedBox(height: 16),

            // ── Holiday list ──────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Holidays',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    Text(
                      '${_holidays.length} date${_holidays.length == 1 ? '' : 's'}',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.grey[600]),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded,
                          color: Color(0xFF629E5C), size: 20),
                      onPressed: _loadHolidays,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildHolidayList(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHolidayList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: Color(0xFF629E5C)),
        ),
      );
    }
    if (_holidays.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(Icons.event_busy, color: Colors.grey[400], size: 40),
              const SizedBox(height: 10),
              Text('No public holidays added yet.',
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    // Group by year
    final Map<int, List<PublicHoliday>> grouped = {};
    for (final h in _holidays) {
      grouped.putIfAbsent(h.date.year, () => []).add(h);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Text(
                '${entry.key}',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700]),
              ),
            ),
            ...entry.value.map((h) => _holidayTile(h)),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  Widget _holidayTile(PublicHoliday item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E9F0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${item.date.day}',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4D7C4A)),
                ),
                Text(
                  _monthAbbr(item.date.month),
                  style: GoogleFonts.poppins(
                      fontSize: 10, color: const Color(0xFF4D7C4A)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                Text(_formatDate(item.date),
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          IconButton(
            icon:
                Icon(Icons.delete_outline, color: Colors.red[400], size: 20),
            onPressed: () => _deleteHoliday(item),
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco({String? hint}) => InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: Color(0xffefefef), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: Color(0xFF629E5C), width: 2),
        ),
      );

  String _formatDate(DateTime d) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday]}, ${d.day} ${months[d.month]} ${d.year}';
  }

  String _monthAbbr(int month) {
    const abbr = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return abbr[month];
  }
}
