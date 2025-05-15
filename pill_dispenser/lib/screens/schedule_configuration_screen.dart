// lib/screens/schedule_configuration_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pill_dispenser/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleConfigurationScreen extends StatefulWidget {
  const ScheduleConfigurationScreen({super.key});

  @override
  State<ScheduleConfigurationScreen> createState() =>
      _ScheduleConfigurationScreenState();
}

class _ScheduleConfigurationScreenState
    extends State<ScheduleConfigurationScreen> {
  late Future<List<Map<String, dynamic>>> _compartmentsFuture;
  final Map<int, Set<int>> compartmentSelectedDays = {};
  final Map<int, TimeOfDay?> compartmentDispenseTime = {};
  final Map<int, int> compartmentQuantity = {};

  List<Map<String, dynamic>>? compartmentsFromSnapshot;

  @override
  void initState() {
    super.initState();
    _compartmentsFuture = _fetchCompartments();
  }

  Future<List<Map<String, dynamic>>> _fetchCompartments() async {
    final dispenserId =
        Provider.of<AuthProvider>(context, listen: false).dispenserId;
    if (dispenserId == null) return [];

    try {
      print("Fetching compartments with dispenser ID: $dispenserId");

      final response = await Supabase.instance.client
          .from('compartments')
          .select(
            'id, compartment_index, current_quantity, medication_id, medication:medication_id (custom_name), schedules(dispense_time, quantity_to_dispense, days_of_week)',
          )
          .eq('dispenser_id', dispenserId)
          .order('compartment_index', ascending: true);

      print("Fetched compartments: $response"); // ← Debugging output

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetching compartments: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 242, 243, 244),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        centerTitle: true,
        title: Text(
          "Schedule Configuration",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _compartmentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final compartments = snapshot.data ?? [];
                  compartmentsFromSnapshot = compartments;

                  for (var i = 0; i < compartments.length; i++) {
                    if (!compartmentSelectedDays.containsKey(i)) {
                      compartmentSelectedDays[i] = {};
                    }
                    if (!compartmentDispenseTime.containsKey(i)) {
                      compartmentDispenseTime[i] = null;
                    }
                    if (!compartmentQuantity.containsKey(i)) {
                      compartmentQuantity[i] = 1;
                    }
                  }

                  if (compartments.isEmpty) {
                    return Center(
                      child: Text(
                        "No compartments found.\nPlease add medications first.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: compartments.length,
                    itemBuilder: (context, index) {
                      final compartment = compartments[index];
                      final compartmentId =
                          compartment['id'].toString(); // ✅ Use toString()

                      return _buildCompartmentCard(
                        context,
                        compartment,
                        index,
                        compartmentId,
                      );
                    },
                  );
                },
              ),
            ),

            // 🚀 Save All Schedules Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed:
                    () => _saveAllSchedules(compartmentsFromSnapshot ?? []),
                icon: const Icon(Icons.save, size: 16),
                label: const Text("Save All Schedules"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 239, 255, 61),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompartmentCard(
    BuildContext context,
    Map<String, dynamic> compartment,
    int index,
    String compartmentId,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Compartment ${index + 1}",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Icon(LucideIcons.clock, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            if (compartment['medication'] != null)
              Text(
                "${compartment['medication']['custom_name']}",
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700]),
              ),
            const SizedBox(height: 16),
            _buildTimePicker(index),
            const SizedBox(height: 16),
            _buildQuantitySelector(index),
            const SizedBox(height: 16),
            _buildDaysOfWeekSelector(index),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(int compartmentIndex) {
    final TimeOfDay? selectedTime = compartmentDispenseTime[compartmentIndex];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Dispense Time",
          style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            final pickedTime = await showTimePicker(
              context: context,
              initialTime: selectedTime ?? TimeOfDay.now(),
            );

            if (pickedTime != null) {
              setState(() {
                compartmentDispenseTime[compartmentIndex] = pickedTime;
              });
            }
          },
          icon: const Icon(Icons.access_time, size: 16),
          label: Text(
            selectedTime?.format(context) ?? "Set Time",
            style: GoogleFonts.inter(fontSize: 14),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 239, 255, 61),
            foregroundColor: Colors.black,
            elevation: 0,
            minimumSize: const Size(100, 36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector(int compartmentIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Quantity",
          style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        DropdownButton<int>(
          value: compartmentQuantity[compartmentIndex],
          items:
              List.generate(10, (i) => i + 1).map((quantity) {
                return DropdownMenuItem(
                  value: quantity,
                  child: Text(quantity.toString()),
                );
              }).toList(),
          onChanged: (int? newValue) {
            setState(() {
              compartmentQuantity[compartmentIndex] = newValue!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDaysOfWeekSelector(int compartmentIndex) {
    final List<String> days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    final Set<int> selectedDays =
        compartmentSelectedDays[compartmentIndex] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Repeat Days",
          style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: List.generate(7, (index) {
            return ChoiceChip(
              label: Text(days[index]),
              selected: selectedDays.contains(index),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedDays.add(index);
                  } else {
                    selectedDays.remove(index);
                  }
                });
              },
              side: BorderSide(
                color:
                    selectedDays.contains(index)
                        ? Colors.green
                        : Colors.grey.shade400,
                width: 1,
              ),
              selectedColor: Colors.green.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
      ],
    );
  }

  bool _isSaving = false; // Add this flag at the class level

  Future<void> _saveAllSchedules(
    List<Map<String, dynamic>> compartments,
  ) async {
    if (_isSaving) return; // Prevent multiple calls
    _isSaving = true;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not authenticated")));
      _isSaving = false; // Reset the flag
      return;
    }

    for (var i = 0; i < compartments.length; i++) {
      final compartment = compartments[i];
      final compartmentId = compartment['id'].toString();
      final selectedDayIndices = compartmentSelectedDays[i];
      final dispenseTime = compartmentDispenseTime[i];
      final quantity = compartmentQuantity[i];

      if (selectedDayIndices != null &&
          selectedDayIndices.isNotEmpty &&
          dispenseTime != null) {
        final dayNames =
            selectedDayIndices
                .map(
                  (dayIndex) =>
                      [
                        'Sun',
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                      ][dayIndex],
                )
                .toList();

        final now = DateTime.now();
        final selectedDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          dispenseTime.hour,
          dispenseTime.minute,
        );

        // Convert start_date and end_date to ISO 8601 format with timezone
        final startDate = DateTime.now().toUtc().toIso8601String();
        final endDate =
            DateTime.now()
                .add(const Duration(days: 30))
                .toUtc()
                .toIso8601String();

        await Supabase.instance.client.from('schedules').insert({
          'user_id': userId,
          'compartment_id': compartmentId,
          'dispense_time': selectedDateTime.toIso8601String(),
          'quantity_to_dispense': quantity,
          'is_active': true,
          'start_date': startDate, // Use ISO 8601 format
          'end_date': endDate, // Use ISO 8601 format
          'days_of_week': dayNames,
        });

        await Supabase.instance.client
            .from('compartments')
            .update({'current_quantity': quantity})
            .eq('id', compartmentId);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All schedules saved successfully!")),
    );

    _isSaving = false; // Reset the flag
    // Navigator.pop(context); // Navigate back
  }
}
