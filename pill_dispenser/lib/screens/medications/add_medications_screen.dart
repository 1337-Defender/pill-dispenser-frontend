// lib/screens/medications/add_medications_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/medication.dart'; // ← Import Medication model
import '../../providers/medication_provider.dart'; // ← Import provider

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  _AddMedicationScreenState createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _scheduleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Medication")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Medication Name"),
                validator: (value) =>
                    value!.isEmpty ? "Please enter a medication name" : null,
              ),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Quantity"),
                validator: (value) =>
                    value!.isEmpty ? "Please enter a quantity" : null,
              ),
              TextFormField(
                controller: _scheduleController,
                decoration: const InputDecoration(labelText: "Schedule (e.g., 8 AM, 3 PM)"),
                validator: (value) =>
                    value!.isEmpty ? "Please enter a schedule" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final medication = Medication(
                      id: DateTime.now().toString(),
                      name: _nameController.text,
                      quantity: int.parse(_quantityController.text),
                      schedule: _scheduleController.text,
                    );

                    Provider.of<MedicationProvider>(context, listen: false)
                        .addMedication(medication);

                    Navigator.pop(context);
                  }
                },
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}