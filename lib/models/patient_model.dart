class Patient {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime birthDate;
  final String
      password; // This should be handled securely, not stored in plain text
  final bool biometricAuthEnabled;
  final String subscriptionType; // 'free', 'standard', 'premium'
  final String? doctorId;

  Patient({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.password,
    required this.biometricAuthEnabled,
    required this.subscriptionType,
    this.doctorId,
  });

  // Method to convert a Patient object to a map, useful for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'birthDate': birthDate.toIso8601String(),
      'biometricAuthEnabled': biometricAuthEnabled,
      'subscriptionType': subscriptionType,
      'doctorId': doctorId,
    };
  }

  // Factory constructor to create a Patient object from a map
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      birthDate: DateTime.parse(map['birthDate']),
      password: '', // Password should not be retrieved from the database
      biometricAuthEnabled: map['biometricAuthEnabled'],
      subscriptionType: map['subscriptionType'],
      doctorId: map['doctorId'],
    );
  }
}
