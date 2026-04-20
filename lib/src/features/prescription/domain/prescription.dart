// Info: Prescription data model for the NMSC application.

class Prescription {
  //▫️Variables
  final int id;
  final DateTime prescribedDate;
  final String doctorName;
  final String? doctorNotes;
  final List<Medication> medications;
  final String status; // 'current' or 'history'
  final String userId;
  final DateTime updatedAt;
  final String? prescriptionFile; // NEW — filename of uploaded PDF (view-only)

  //▫️Constructor
  Prescription({
    required this.id,
    required this.prescribedDate,
    required this.doctorName,
    this.doctorNotes,
    required this.medications,
    required this.status,
    required this.userId,
    required this.updatedAt,
    this.prescriptionFile, // NEW
  });

  //▫️Converter functions
  factory Prescription.fromJson(Map<String, dynamic> json) {
    final medicationsJson = json['medications'] as List<dynamic>? ?? [];
    return Prescription(
      id: int.parse(json['prescription_id'].toString()),
      prescribedDate: DateTime.parse(json['prescribed_date']),
      doctorName: json['doctor_name'] as String,
      doctorNotes: json['doctor_notes'] as String?,
      medications: medicationsJson
          .map((m) => Medication.fromJson(m as Map<String, dynamic>))
          .toList(),
      status: json['prescription_status'] as String,
      userId: json['user_id'] as String,
      updatedAt: DateTime.parse(json['updated_at']).toUtc(),
      prescriptionFile: json['prescription_file'] as String?, // NEW
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'prescribedDate': prescribedDate.toIso8601String(),
      'doctorName': doctorName,
      'doctorNotes': doctorNotes,
      'medications': medications.map((m) => m.toJson()).toList(),
      'status': status,
      'userId': userId,
      'prescriptionFile': prescriptionFile, // NEW
    };
  }
}

class Medication {
  //▫️Variables
  final int? id;
  final String name;
  final String quantity;
  final String instructions;

  //▫️Constructor
  Medication({
    this.id,
    required this.name,
    required this.quantity,
    required this.instructions,
  });

  //▫️Converter functions
  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['medication_id'] != null
          ? int.parse(json['medication_id'].toString())
          : null,
      name: json['medication_name'] as String,
      quantity: json['medication_quantity'] as String,
      instructions: json['medication_instructions'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id?.toString(),
      'name': name,
      'quantity': quantity,
      'instructions': instructions,
    };
  }
}
