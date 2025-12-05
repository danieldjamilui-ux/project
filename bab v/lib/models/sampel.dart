class SwabDarah {
  final String id;
  final String name;
  final String species;
  final String testDate;
  final String testType;
  String outcome;
  String status;

  SwabDarah({
    required this.id,
    required this.name,
    required this.species,
    required this.testDate,
    required this.testType,
    this.outcome = "Negatif",
    this.status = "Belum Selesai",
  });

  factory SwabDarah.fromMap(String docId, Map<String, dynamic> map) {
    return SwabDarah(
      id: map["animalId"] ?? "",
      name: map["animalName"] ?? "",
      species: map["species"] ?? "",
      testDate: map["testDate"] ?? "",
      testType: map["testType"] ?? "",
      outcome: map["outcome"] ?? "Negatif",
      status: map["status"] ?? "Belum Selesai",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "animalId": id,
      "animalName": name,
      "species": species,
      "testDate": testDate,
      "testType": testType,
      "outcome": outcome,
      "status": status,
    };
  }
}
