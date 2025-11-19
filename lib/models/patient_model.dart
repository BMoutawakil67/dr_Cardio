import 'package:hive/hive.dart';

part 'patient_model.g.dart';

@HiveType(typeId: 0)
class Patient {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String phoneNumber;

  @HiveField(5)
  final String address;

  @HiveField(6)
  final DateTime birthDate;

  @HiveField(7)
  final String gender;

  @HiveField(8)
  final String? profileImageUrl;

  @HiveField(9)
  final String? assignedDoctorId;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.birthDate,
    required this.gender,
    this.profileImageUrl,
    this.assignedDoctorId,
  });

  Patient copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? address,
    DateTime? birthDate,
    String? gender,
    String? profileImageUrl,
    String? assignedDoctorId,
  }) {
    return Patient(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      assignedDoctorId: assignedDoctorId ?? this.assignedDoctorId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Patient &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          email == other.email &&
          phoneNumber == other.phoneNumber &&
          address == other.address &&
          birthDate == other.birthDate &&
          gender == other.gender &&
          profileImageUrl == other.profileImageUrl &&
          assignedDoctorId == other.assignedDoctorId;

  @override
  int get hashCode =>
      id.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      email.hashCode ^
      phoneNumber.hashCode ^
      address.hashCode ^
      birthDate.hashCode ^
      gender.hashCode ^
      profileImageUrl.hashCode ^
      assignedDoctorId.hashCode;
}
