class AdminCompletedMission {
  final String driverName;
  final String driverPhone;
  final String carNumber;
  final String mosqueName;
  final double amount;
  final DateTime collectionDate;

  AdminCompletedMission({
    required this.driverName,
    required this.driverPhone,
    required this.carNumber,
    required this.mosqueName,
    required this.amount,
    required this.collectionDate,
  });

  factory AdminCompletedMission.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'] ?? {};

    return AdminCompletedMission(
      driverName: "${driver['name'] ?? ''} ${driver['famillyname'] ?? ''}".trim(),
      driverPhone: driver['phone'] ?? '',
      carNumber: driver['car_number'] ?? '',
      mosqueName: json['mosqueName'] ?? '',
      amount: double.tryParse(json['collectedMoney'].toString()) ?? 0.0,
      collectionDate: DateTime.tryParse(json['collectionDate'] ?? '') ?? DateTime.now(),
    );
  }
}
class CollectedReport {
  final int totalCollectedMoney;
  final List<AdminCompletedMission> missionDetails;

  CollectedReport({
    required this.totalCollectedMoney,
    required this.missionDetails,
  });

  factory CollectedReport.fromJson(Map<String, dynamic> json) {
    return CollectedReport(
      totalCollectedMoney: json['totalCollectedMoney'],
      missionDetails: (json['missionDetails'] as List)
          .map((item) => AdminCompletedMission.fromJson(item))
          .toList(),
    );
  }
}
