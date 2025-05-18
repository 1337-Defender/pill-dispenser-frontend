import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  Map<String, dynamic>? _selectedMedComp;
  List<Map<String, dynamic>> _medCompOptions = [];
  List<int> _selectedDays = [];
  TimeOfDay? _selectedTime;
  int _quantity = 1;
  bool _isLoading = false;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _repeatForever = true;

  @override
  void initState() {
    super.initState();
    _fetchMedCompOptions();
  }

  Future<void> _fetchMedCompOptions() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
    final disepnserId = Provider.of<AuthProvider>(context, listen: false).dispenserId;
    if (userId == null) return;
    // Get compartments joined with medication info
    final result = await Supabase.instance.client
        .from('compartments')
        .select('id, compartment_index, medication_id, medications!inner(id, custom_name, custom_strength)')
        .eq('dispenser_id', disepnserId!)
        .not('medication_id', 'is', null);

    setState(() {
      _medCompOptions = List<Map<String, dynamic>>.from(result);
    });
  }

  Future<void> _save() async {
    if (_selectedMedComp == null || _selectedTime == null || _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
    final timeStr = _selectedTime!.format(context);
    final timeParts = timeStr.split(":");
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1].split(' ')[0]);
    final isPm = timeStr.toLowerCase().contains('pm');
    final hour24 = isPm && hour != 12 ? hour + 12 : (!isPm && hour == 12 ? 0 : hour);
    final formattedTime = "${hour24.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00";

    await Supabase.instance.client.from('schedules').insert({
      'user_id': userId,
      'medication_id': _selectedMedComp!['medication_id'],
      'compartment_id': _selectedMedComp!['id'],
      'days_of_week': _selectedDays,
      'dispense_time': formattedTime,
      'quantity_to_dispense': _quantity,
      'is_active': true,
      'start_date': DateTime.now().toIso8601String().substring(0, 10),
      'end_date': null,
    });
    setState(() => _isLoading = false);
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView(
            children: [
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(LucideIcons.chevronLeft, color: Colors.black),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      children: [
                        IconButton(
                          icon: Icon(LucideIcons.bell, color: Colors.black),
                          onPressed: () {},
                        ),
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(LucideIcons.userRound, color: Colors.black),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                "Add Schedule",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 24),
              // Medication+Compartment dropdown
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<Map<String, dynamic>>(
                  value: _selectedMedComp,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  ),
                  hint: Text("Select Medication & Compartment", style: GoogleFonts.inter(fontSize: 16)),
                  items: _medCompOptions
                      .map((item) => DropdownMenuItem<Map<String, dynamic>>(
                            value: item,
                            child: Text(
                              "${item['medications']['custom_name'] ?? 'Unnamed'}"
                              "${item['medications']['custom_strength'] != null ? ' (${item['medications']['custom_strength']})' : ''} "
                              "- Compartment ${item['compartment_index']}",
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedMedComp = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Days of week selector (white chips, single row)
              Text("Days of Week", style: GoogleFonts.inter(fontSize: 16)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(7, (i) {
                    const weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: ChoiceChip(
                        label: Text(weekDays[i]),
                        selected: _selectedDays.contains(i),
                        selectedColor: Colors.black12,
                        backgroundColor: Colors.white,
                        labelStyle: GoogleFonts.inter(
                          color: _selectedDays.contains(i) ? Colors.black : Colors.black,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDays.add(i);
                            } else {
                              _selectedDays.remove(i);
                            }
                          });
                        },
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              // Time picker
              Row(
                children: [
                  Text("Dispense Time", style: GoogleFonts.inter(fontSize: 16)),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedTime = picked;
                        });
                      }
                    },
                    child: Text(
                      _selectedTime != null
                          ? _selectedTime!.format(context)
                          : "Select Time",
                      style: GoogleFonts.inter(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Quantity picker
              Row(
                children: [
                  Text("Quantity", style: GoogleFonts.inter(fontSize: 16)),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (_quantity > 1) _quantity -= 1;
                            });
                          },
                        ),
                        SizedBox(
                          width: 40,
                          child: Center(
                            child: Text(
                              '$_quantity',
                              style: GoogleFonts.inter(fontSize: 16),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              _quantity += 1;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Start Date picker
              Row(
                children: [
                  Text("Start Date", style: GoogleFonts.inter(fontSize: 16)),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _startDate = picked;
                          if (_endDate != null && _endDate!.isBefore(_startDate)) {
                            _endDate = _startDate;
                          }
                        });
                      }
                    },
                    child: Text(
                      "${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}",
                      style: GoogleFonts.inter(fontSize: 16),
                    ),
                  ),
                ],
              ),
              // Repeat forever switch
              Row(
                children: [
                  Text("Repeat forever", style: GoogleFonts.inter(fontSize: 16)),
                  const Spacer(),
                  Switch(
                    value: _repeatForever,
                    onChanged: (val) {
                      setState(() {
                        _repeatForever = val;
                        if (val) _endDate = null;
                      });
                    },
                  ),
                ],
              ),
              // End Date picker (only if not repeating forever)
              if (!_repeatForever)
                Row(
                  children: [
                    Text("End Date", style: GoogleFonts.inter(fontSize: 16)),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? _startDate,
                          firstDate: _startDate,
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _endDate = picked;
                          });
                        }
                      },
                      child: Text(
                        _endDate != null
                            ? "${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}": "Select End Date",
                        style: GoogleFonts.inter(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEFFF3D),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Save", style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}