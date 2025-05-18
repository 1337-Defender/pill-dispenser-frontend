import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class ScheduleManagementScreen extends StatefulWidget {
  const ScheduleManagementScreen({super.key});

  @override
  State<ScheduleManagementScreen> createState() => _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen> {
  late Future<List<Map<String, dynamic>>> _schedulesFuture;

  @override
  void initState() {
    super.initState();
    _schedulesFuture = _fetchSchedules();
  }

  Future<List<Map<String, dynamic>>> _fetchSchedules() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
    if (userId == null) return [];
    final response = await Supabase.instance.client
        .from('schedules')
        .select('*, compartments:compartment_id(compartment_index), medications:medication_id(custom_name, custom_strength)')
        .eq('user_id', userId)
        .order('dispense_time', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF2F3F4),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
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
            Row(
              children: [
                Text(
                  "Manage Schedules",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(LucideIcons.plus, color: Colors.black),
                  onPressed: () async {
                    await context.push('/add_schedule');
                    setState(() {
                      _schedulesFuture = _fetchSchedules();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _schedulesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final schedules = snapshot.data ?? [];
                  if (schedules.isEmpty) {
                    return Center(
                      child: Text(
                        "No schedules found.",
                        style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[700]),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: schedules.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final s = schedules[i];
                      final medName = s['medications']?['custom_name'] ?? 'Medication';
                      final medStrength = s['medications']?['custom_strength'] ?? '';
                      final compIndex = s['compartments']?['compartment_index']?.toString() ?? '';
                      final daysOfWeek = (s['days_of_week'] as List<dynamic>?)?.cast<int>() ?? [];
                      final dispenseTime = s['dispense_time'] as String? ?? '';
                      final quantity = s['quantity_to_dispense']?.toString() ?? '';
                      final startDate = s['start_date'];
                      final endDate = s['end_date'];
                      final isActive = s['is_active'] == true;

                      // Format days of week
                      const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                      final daysText = daysOfWeek.isNotEmpty
                          ? daysOfWeek.map((d) => weekDays[d % 7]).join(', ')
                          : '—';

                      // Format time
                      final timeParts = dispenseTime.split(':');
                      final formattedTime = timeParts.length >= 2
                          ? TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]))
                          : null;

                      return GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(LucideIcons.clock, color: Colors.black),
                                  const SizedBox(width: 8),
                                  Text(
                                    formattedTime != null
                                        ? MaterialLocalizations.of(context).formatTimeOfDay(formattedTime)
                                        : dispenseTime,
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
                                  ),
                                  const Spacer(),
                                  if (isActive)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text("Active", style: GoogleFonts.inter(color: Colors.green[800], fontSize: 12)),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text("Inactive", style: GoogleFonts.inter(color: Colors.red[800], fontSize: 12)),
                                    ),
                                  // 3-dot menu button
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: Colors.black),
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        await context.push('/edit_schedule/${s['id']}');
                                        setState(() {
                                          _schedulesFuture = _fetchSchedules();
                                        });
                                      } else if (value == 'delete') {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Schedule'),
                                            content: const Text('Are you sure you want to delete this schedule?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(true),
                                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await Supabase.instance.client
                                              .from('schedules')
                                              .delete()
                                              .eq('id', s['id']);
                                          setState(() {
                                            _schedulesFuture = _fetchSchedules();
                                          });
                                        }
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "$medName ${medStrength.isNotEmpty ? '($medStrength)' : ''}",
                                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Compartment: $compIndex",
                                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Days: $daysText",
                                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Quantity: $quantity",
                                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Start: $startDate",
                                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
                              ),
                              Text(
                                "End: ${endDate ?? 'Forever'}",
                                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}