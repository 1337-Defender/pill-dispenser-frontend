import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pill_dispenser/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  late Future<List<Map<String, dynamic>>> _compartmentsFuture;
  late Future<List<Map<String, dynamic>>> _medicationsFuture;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  void _fetchAll() {
    setState(() {
      _compartmentsFuture = _fetchCompartments();
      _medicationsFuture = _fetchMedications();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchCompartments() async {
    final dispenserId =
        Provider.of<AuthProvider>(context, listen: false).dispenserId;
    if (dispenserId == null) return [];
    try {
      final response = await Supabase.instance.client
          .from('compartments')
          .select(
            'id, compartment_index, current_quantity, medication:medication_id (custom_name, custom_description, custom_strength)',
          )
          .eq('dispenser_id', dispenserId)
          .order('compartment_index', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetching compartments: $e");
      throw Exception(e);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchMedications() async {
    final userId =
        Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
    if (userId == null) return [];
    try {
      final response = await Supabase.instance.client
          .from('medications')
          .select('id, custom_name, custom_description, custom_strength')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetching medications: $e");
      throw Exception(e);
    }
  }

  // Stub for options menu (implement as needed)
  void _showOptionsMenu(BuildContext context, Offset offset,
      String medicationName, int index) async {
    // TODO: Implement menu
  }

  // Stub for edit dialog (implement as needed)
  void _showEditQuantityDialog(String medicationName, int index) {
    // TODO: Implement dialog
  }

  // Dummy refill text logic, replace with your own
  String _refillText(int? quantity) {
    if (quantity == null) return '';
    if (quantity > 30) return 'Refill in 1 month';
    if (quantity > 14) return 'Refill in 2 weeks';
    if (quantity > 7) return 'Refill in 10 days';
    if (quantity > 3) return 'Refill in 3 days';
    return 'Refill soon';
  }

  @override
  Widget build(BuildContext context) {
    final dispenserId =
        Provider.of<AuthProvider>(context, listen: false).dispenserId;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 242, 243, 244),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
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

            return ListView(
              children: [
                const SizedBox(height: 48),
                Text(
                  "Compartments",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: compartments.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final compartment = compartments[index];
                    final med = compartment['medication'];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${compartment['compartment_index']}',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            med?['custom_name'] ?? 'Empty',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${compartment['current_quantity'] ?? 0} doses left',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _refillText(compartment['current_quantity']),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              height: 24,
                              width: 24,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 239, 255, 61),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    LucideIcons.chevronRight,
                                    size: 16,
                                  ),
                                  onPressed: () async {
                                    await context.push(
                                      '/configure_compartment/${compartment['id']}/${compartment['compartment_index']}',
                                    );
                                    _fetchAll();
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
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Medications",
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push('/add_medication');
                      },
                      icon: const Icon(Icons.add, color: Colors.black),
                      label: const Text("Add"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          239,
                          255,
                          61,
                        ),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _medicationsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final medications = snapshot.data ?? [];
                    if (medications.isEmpty) {
                      return Text(
                        "No medications found.",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      );
                    }
                    return Column(
                      children: medications.map((med) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.medication,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    med['custom_name'] ?? 'Unnamed',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "${med['custom_description'] ?? ''}${med['custom_description'] != null && med['custom_strength'] != null ? ' • ' : ''}${med['custom_strength'] ?? ''}",
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.more_horiz),
                                onPressed: () {
                                  // TODO: Show medication options
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
