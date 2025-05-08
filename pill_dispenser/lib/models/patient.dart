class Patient {
  final String id;
  final String name;
  final String dob;
  final String contact;
  final String? allergies; // ← Fixed from 'allergies' to 'allergies'

  Patient({
    required this.id,
    required this.name,
    required this.dob,
    required this.contact,
    this.allergies, // ← Fixed here too
  });
}