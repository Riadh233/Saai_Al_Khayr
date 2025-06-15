import 'package:maps_app/data/models/user.dart';

class CompletedMission {
  final int missionId;
  final String mosqueName;
  final String mosqueAddress;
  final User driver;
  final String amount;
  final String? amountArabic;
  final bool alreadyAdded;

  CompletedMission({
    required this.missionId,
    required this.mosqueName,
    required this.mosqueAddress,
    required this.driver,
    required this.amount,
    this.amountArabic,
    required this.alreadyAdded,
  });

  factory CompletedMission.fromJson(Map<String, dynamic> json) {
    final mosque = json['mosque'];
    final collected = json['collectedMoney'];
    return CompletedMission(
      missionId: json['missionId'],
      mosqueName: mosque['name'],
      mosqueAddress: mosque['address'],
      driver: User.fromDriverJson(json['driver']),
      amount: collected['amount'],
      amountArabic: collected['amount_arabic'],
      alreadyAdded: collected['alreadyAdded'],
    );
  }
}
