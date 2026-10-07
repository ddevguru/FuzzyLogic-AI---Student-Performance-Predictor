class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final StudentProfile? profile;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'student',
      profile: json['profile'] != null ? StudentProfile.fromJson(json['profile']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profile': profile?.toJson(),
    };
  }
}

class StudentProfile {
  final String? id;
  final String rollNumber;
  final String course;
  final int semester;
  final String department;

  StudentProfile({
    this.id,
    required this.rollNumber,
    required this.course,
    required this.semester,
    required this.department,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id']?.toString(),
      rollNumber: json['roll_number'] ?? json['rollNumber'] ?? 'N/A',
      course: json['course'] ?? 'B.Tech CS',
      semester: json['semester'] is int ? json['semester'] : int.tryParse(json['semester']?.toString() ?? '6') ?? 6,
      department: json['department'] ?? 'Computer Science',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rollNumber': rollNumber,
      'course': course,
      'semester': semester,
      'department': department,
    };
  }
}
