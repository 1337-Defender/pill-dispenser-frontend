import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  int selectedDayOffset = 0;
  late DateTime today;
  late List<DateTime> weekDays;
  List<Map<String, dynamic>> schedules = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    weekDays = List.generate(7, (i) => today.add(Duration(days: i)));
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    setState(() => isLoading = true);
    final userId =
        Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
    if (userId == null) return;
    final start = weekDays.first;
    final end = weekDays.last;

    final response = await Supabase.instance.client
        .from('schedules')
        .select(
          '*, compartments:compartment_id(medications:medication_id(custom_name), compartment_index)',
        )
        .eq('user_id', userId)
        .lte('start_date', start.toIso8601String().substring(0, 10))
        .or(
          'end_date.is.null,end_date.gte.${end.toIso8601String().substring(0, 10)}',
        )
        .eq('is_active', true);
    print("HEREEEEEE $response");

    setState(() {
      schedules = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Find the literal next schedule across all days in the week
    String? nextScheduleId;
    DateTime? nextScheduleDateTime;

    for (final s in schedules) {
      final time = s['dispense_time'] as String;
      final timeParts = time.split(':');
      final daysOfWeek = List<int>.from(s['days_of_week'] ?? []);
      // Check for specific_date
      if (s['specific_date'] != null) {
        final d = DateTime.parse(s['specific_date']);
        final scheduleDateTime = DateTime(
          d.year,
          d.month,
          d.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
        if (scheduleDateTime.isAfter(DateTime.now())) {
          if (nextScheduleDateTime == null ||
              scheduleDateTime.isBefore(nextScheduleDateTime)) {
            nextScheduleDateTime = scheduleDateTime;
            nextScheduleId = s['id'].toString();
          }
        }
      } else {
        // For each day in the week, check if this schedule applies
        for (final d in weekDays) {
          final weekdayIndex = d.weekday % 7;
          if (daysOfWeek.contains(weekdayIndex)) {
            final scheduleDateTime = DateTime(
              d.year,
              d.month,
              d.day,
              int.parse(timeParts[0]),
              int.parse(timeParts[1]),
            );
            if (scheduleDateTime.isAfter(DateTime.now())) {
              if (nextScheduleDateTime == null ||
                  scheduleDateTime.isBefore(nextScheduleDateTime)) {
                nextScheduleDateTime = scheduleDateTime;
                nextScheduleId =
                    s['id'].toString() + scheduleDateTime.toIso8601String();
              }
            }
          }
        }
      }
    }
    final selectedDate = weekDays[selectedDayOffset];
    final selectedDateStr = selectedDate.toIso8601String().substring(0, 10);

    // Filter and group schedules for the selected day
    final daySchedules =
        schedules.where((s) {
          // If specific_date is set, match it; else, check days_of_week
          if (s['specific_date'] != null) {
            return s['specific_date'] == selectedDateStr;
          }
          final daysOfWeek = List<int>.from(s['days_of_week'] ?? []);
          final weekdayIndex =
              selectedDate.weekday % 7; // 0 = Sunday, 6 = Saturday
          return daysOfWeek.contains(weekdayIndex);
        }).toList();

    // Sort by dispense_time
    daySchedules.sort(
      (a, b) => (a['dispense_time'] as String).compareTo(
        b['dispense_time'] as String,
      ),
    );

    // Find the next schedule (after now)
    final now = DateTime.now();
    int? nextIndex;
    for (int i = 0; i < daySchedules.length; i++) {
      final t = daySchedules[i]['dispense_time'] as String;
      final timeParts = t.split(':');
      final scheduleTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
      if (scheduleTime.isAfter(now)) {
        nextIndex = i;
        break;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F4),
      // appBar: AppBar(
      //   elevation: 0,
      //   backgroundColor: Colors.transparent,
      //   centerTitle: true,
      //   title: Text("Schedule", style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.black)),
      //   actions: [
      //     Padding(
      //       padding: const EdgeInsets.only(right: 24),
      //       child: ElevatedButton.icon(
      //         onPressed: () {
      //           // TODO: Navigate to add schedule screen
      //         },
      //         icon: const Icon(Icons.add, color: Colors.black),
      //         label: const Text("Add", style: TextStyle(color: Colors.black)),
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: const Color(0xFFEFFF3D),
      //           foregroundColor: Colors.black,
      //           elevation: 0,
      //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 48),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Schedule",
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "View schedule for next 7 days",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            // TODO: Implement add functionality
                            await context.push('/manage_schedules');
                            _fetchSchedules();
                          },
                          icon: const Icon(LucideIcons.pencil, color: Colors.black, size: 14,),
                          label: Text(
                            "Edit",
                            style: GoogleFonts.inter(color: Colors.black, fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEFFF3D),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Date selector
                    SizedBox(
                      height: 70,
                      child: Row(
                        children: List.generate(weekDays.length * 2 - 1, (i) {
                          if (i.isOdd) {
                            // Insert a 6px gap between items
                            return const SizedBox(width: 6);
                          }
                          final index = i ~/ 2;
                          final d = weekDays[index];
                          final isSelected = index == selectedDayOffset;
                          return Expanded(
                            child: AspectRatio(
                              aspectRatio: 0.8,
                              child: GestureDetector(
                                onTap:
                                    () => setState(
                                      () => selectedDayOffset = index,
                                    ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? Colors.black
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        [
                                          'Sun',
                                          'Mon',
                                          'Tue',
                                          'Wed',
                                          'Thu',
                                          'Fri',
                                          'Sat',
                                        ][d.weekday % 7],
                                        style: GoogleFonts.inter(
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        d.day.toString(),
                                        style: GoogleFonts.inter(
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : Colors.black,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child:
                          daySchedules.isEmpty
                              ? Center(
                                child: Text(
                                  "No schedules for this day.",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              )
                              : ListView.builder(
                                itemCount: daySchedules.length,
                                itemBuilder: (context, i) {
                                  final s = daySchedules[i];
                                  // final isNext = i == nextIndex;
                                  final medName =
                                      s['compartments']?['medications']?['custom_name'] ??
                                      'Medication';
                                  final compIndex =
                                      s['compartments']?['compartment_index']
                                          ?.toString() ??
                                      '';
                                  final time = s['dispense_time'] as String;
                                  final hourMin = time.substring(
                                    0,
                                    5,
                                  ); // "HH:mm"
                                  final timeOfDay = TimeOfDay(
                                    hour: int.parse(time.split(":")[0]),
                                    minute: int.parse(time.split(":")[1]),
                                  );
                                  final formattedTime =
                                      MaterialLocalizations.of(
                                        context,
                                      ).formatTimeOfDay(
                                        timeOfDay,
                                        alwaysUse24HourFormat: false,
                                      );
                                  final timeParts = time.split(':');
                                  final scheduleDateTime = DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    int.parse(timeParts[0]),
                                    int.parse(timeParts[1]),
                                  );
                                  final uniqueScheduleKey =
                                      s['id'].toString() +
                                      scheduleDateTime.toIso8601String();
                                  final isNext =
                                      uniqueScheduleKey == nextScheduleId;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .center, // Center vertically
                                      children: [
                                        // Time column
                                        SizedBox(
                                          width: 70,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center, // Center vertically in column
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (isNext)
                                                Text(
                                                  "Next",
                                                  style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              Text(
                                                formattedTime.toLowerCase(),
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Card
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  isNext
                                                      ? const Color(0xFFFAFFC4)
                                                      : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: ListTile(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 0,
                                                  ),
                                              title: Text(
                                                medName,
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              subtitle: Text(
                                                "Compartment $compIndex",
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              trailing: IconButton(
                                                icon: Icon(
                                                  LucideIcons.ellipsis,
                                                ),
                                                onPressed: () {
                                                  // TODO: Show options
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}
