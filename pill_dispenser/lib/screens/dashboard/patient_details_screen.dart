// lib/screens/patient/patient_details_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/patient.dart';
import '../../providers/patient_provider.dart';

class PatientDetailsScreen extends StatefulWidget {
  const PatientDetailsScreen({super.key});

  @override
  _PatientDetailsScreenState createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _contactController = TextEditingController();
  final _allergiesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PatientProvider>(context, listen: false);
    if (provider.patient != null) {
      _nameController.text = provider.patient!.name;
      _dobController.text = provider.patient!.dob;
      _contactController.text = provider.patient!.contact;
      _allergiesController.text = provider.patient!.allergies ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Details"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (value) =>
                    value!.isEmpty ? "Please enter the patient's name" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _dobController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(labelText: "Date of Birth (YYYY-MM-DD)"),
                validator: (value) =>
                    value!.isEmpty ? "Please enter the date of birth" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Contact Number"),
                validator: (value) =>
                    value!.isEmpty ? "Please enter the contact number" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _allergiesController,
                decoration: const InputDecoration(labelText: "Allergies (optional)"),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final patient = Patient(
                      id: Provider.of<PatientProvider>(context, listen: false).patient?.id ?? DateTime.now().toString(),
                      name: _nameController.text,
                      dob: _dobController.text,
                      contact: _contactController.text,
                      allergies: _allergiesController.text.isNotEmpty ? _allergiesController.text : null,
                    );

                    Provider.of<PatientProvider>(context, listen: false).updatePatient(patient);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Patient details updated successfully!")),
                    );

                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}