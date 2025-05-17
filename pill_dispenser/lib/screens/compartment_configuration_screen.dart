import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';

class CompartmentConfigScreen extends StatefulWidget {
  final String compartmentId;
  final int compartmentIndex;
  const CompartmentConfigScreen({
    super.key,
    required this.compartmentId,
    required this.compartmentIndex,
  });

  @override
  State<CompartmentConfigScreen> createState() =>
      _CompartmentConfigScreenState();
}

class _CompartmentConfigScreenState extends State<CompartmentConfigScreen> {
  int? _selectedMedicationId;
  int _quantity = 1;
  bool _loading = true;
  List<Map<String, dynamic>> _medications = [];
  int? _compartmentIndex;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final userId =
        Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
    final compartment =
        await Supabase.instance.client
            .from('compartments')
            .select('id, compartment_index, medication_id, current_quantity')
            .eq('id', widget.compartmentId)
            .single();
    final meds = await Supabase.instance.client
        .from('medications')
        .select('id, custom_name')
        .eq('user_id', userId!);
    setState(() {
      _selectedMedicationId = compartment['medication_id'];
      _quantity = compartment['current_quantity'] ?? 1;
      _compartmentIndex = compartment['compartment_index'];
      _medications = List<Map<String, dynamic>>.from(meds);
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    await Supabase.instance.client
        .from('compartments')
        .update({
          'medication_id': _selectedMedicationId,
          'current_quantity': _quantity,
        })
        .eq('id', widget.compartmentId);
    setState(() => _loading = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Compartment updated!')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F4),
      body: SafeArea(
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
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
                              icon: Icon(
                                LucideIcons.chevronLeft,
                                color: Colors.black,
                              ),
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
                                  icon: Icon(
                                    LucideIcons.bell,
                                    color: Colors.black,
                                  ),
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
                              icon: Icon(
                                LucideIcons.userRound,
                                color: Colors.black,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        "Compartment ${widget.compartmentIndex}",
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<int>(
                          value: _selectedMedicationId,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                          ),
                          hint: Text(
                            "Select Medication",
                            style: GoogleFonts.inter(fontSize: 16),
                          ),
                          items:
                              _medications
                                  .map(
                                    (med) => DropdownMenuItem<int>(
                                      value: med['id'],
                                      child: Text(
                                        med['custom_name'] ?? 'Unnamed',
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedMedicationId = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Text(
                            "Quantity",
                            style: GoogleFonts.inter(fontSize: 16),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
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
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEFFF3D),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child:
                              _loading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    "Save",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement dispense logic
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[300],
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            "Dispense Medication",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
