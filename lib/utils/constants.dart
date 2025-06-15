import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_app/data/models/mosque.dart';

import '../data/models/admin_completed_mission.dart';
import '../data/models/driver_mission.dart';
import '../data/models/mission.dart';
import '../data/models/user.dart';

class Constants{
  static final List<Marker> mosques = [
    Marker(point: LatLng(36.756061,3.442273), child: Icon(Icons.location_on, color: Colors.red))
    //Marker(name: 'a', lat: '', ling: '', distance: '0')
  ];
  static final userLocation = LatLng(36.7477473, 3.4389499);
  static List<String> userRoles = [
    'السائقين',
    'الائمة',
  ];
  static List<String> missionStatusList = [
  'متاحة',
  'قيد التنفيذ',
  ' انتهت'
  ];
  static List<String> userMissionStatus = ['متاحة',
    'قيد التنفيذ',];
  static final List<Mosque> mockMosques = [
    Mosque(
      id: 1,
      name: 'Mosquée El Fath',
      address: 'Bab Ezzouar, Alger',
      lat: '36.7531',
      ling: '3.4665',
      isApproved: true,
      imam: User(
        id: 1,
        firstName: 'Ahmed',
        lastName: 'Benali',
        password: 'pass1234',
        number: '0550123456',
        lat: 36.7531,
        lng: 3.4665,
        status: UserRole.imam,
      ),
    ),
    Mosque(
      id: 2,
      name: 'Mosquée Errahma',
      address: 'Kouba, Alger',
      lat: '36.7284',
      ling: '3.0808',
      isApproved: false,
      imam: User(
        id: 2,
        firstName: 'Mohamed',
        lastName: 'Salah',
        password: 'pass1234',
        number: '0550987654',
        lat: 36.7284,
        lng: 3.0808,
        status: UserRole.imam,
      ),
    ),
    Mosque(
      id: 3,
      name: 'Mosquée En-Nour',
      address: 'Hydra, Alger',
      lat: '36.7487',
      ling: '3.0463',
      isApproved: null,
      imam: null,
    ),
    Mosque(
      id: 4,
      name: 'Mosquée El Hidaya',
      address: 'Bir Mourad Rais, Alger',
      lat: '36.7420',
      ling: '3.0469',
      isApproved: true,
      imam: User(
        id: 3,
        firstName: 'Youssef',
        lastName: 'Kamel',
        password: 'pass1234',
        number: '0550234567',
        lat: 36.7420,
        lng: 3.0469,
        status: UserRole.imam,
      ),
    ),
  ];
  // static final List<DriverMission> mockDriverMissions = [
  //   DriverMission(
  //     id: 1,
  //     mosqueName: 'مسجد النور',
  //     mosqueAddress: 'شارع الثورة، الجزائر',
  //     distance: 2.5,
  //     time: 10.0,
  //     imamName: 'أحمد بن محمد',
  //     imamNumber: '+213 6 12 34 56 78',
  //     status: 'AVAILABLE',
  //   ),
  //   DriverMission(
  //     id: 2,
  //     mosqueName: 'مسجد الفتح',
  //     mosqueAddress: 'حي الربيع، قسنطينة',
  //     distance: 4.8,
  //     time: 15.5,
  //     imamName: 'يوسف بن علي',
  //     imamNumber: '+213 6 11 22 33 44',
  //     status: 'PENDING',
  //   ),
  //   DriverMission(
  //     id: 3,
  //     mosqueName: 'مسجد السلام',
  //     mosqueAddress: 'طريق الجامعة، وهران',
  //     distance: 1.2,
  //     time: 5.0,
  //     imamName: 'خالد بن سعيد',
  //     imamNumber: '+213 6 98 76 54 32',
  //     status: 'COMPLETED',
  //   ),
  //   DriverMission(
  //     id: 4,
  //     mosqueName: 'مسجد الفرقان',
  //     mosqueAddress: 'حي السلام، عنابة',
  //     distance: 3.0,
  //     time: 12.0,
  //     imamName: 'عبد الله بن رشيد',
  //     imamNumber: '+213 6 55 44 33 22',
  //     status: 'PENDING',
  //   ),
  //   DriverMission(
  //     id: 5,
  //     mosqueName: 'مسجد الهداية',
  //     mosqueAddress: 'شارع الاستقلال، بجاية',
  //     distance: 5.6,
  //     time: 20.3,
  //     imamName: 'مصطفى بن زكريا',
  //     imamNumber: '+213 6 77 88 99 00',
  //     status: 'AVAILABLE',
  //   ),
  // ];


  static final List<User> mockUsers = [
    User(
      id: 1,
      firstName: 'Ahmed',
      lastName: 'Benali',
      password: 'pass1234',
      number: '0550123456',
      lat: 36.756061,
      lng: 3.442273,
      status: UserRole.imam,
    ),
    User(
      id: 2,
      firstName: 'Youssef',
      lastName: 'Kacem',
      password: 'securePass',
      number: '0660789012',
      status: UserRole.imam,
    ),
    User(
      id: 3,
      firstName: 'Sami',
      lastName: 'Bouzid',
      password: 'qwerty987',
      number: '0770456123',
      lat: 36.756061,
      lng: 3.442273,
      status: UserRole.imam,
    ),
    User(
      id: 4,
      firstName: 'Karim',
      lastName: 'Zerhouni',
      password: 'karim@2025',
      number: '0650345678',
      lat: 36.756061,
      lng: 3.442273,
      status: UserRole.imam,
    ),
  ];
  static final List<Mission> mockMissions = [
    Mission(
      id: 1,
      mosque: Mosque(name: 'Mosquée El Fath', address: 'Bab Ezzouar',  isApproved: true),
      status: 'available',
      driver: User(firstName: 'Ahmed', lastName: 'Benali', password: '',number: '07899787858', carNumber: '1213-254-569-878'),
    ),
    Mission(
      id: 2,
      mosque: Mosque(name: 'Mosquée Errahma', address: 'Kouba', isApproved: true),
      status: 'pending',
      driver: User(firstName: 'Mohamed', lastName: 'Salah', password: ''),
    ),
    Mission(
      id: 3,
      mosque: Mosque(name: 'Mosquée En-Nour', address: 'Hydra',isApproved: true),
      status: 'completed',
      driver: User(firstName: 'Youssef', lastName: 'Kamel', password: ''),
    ),
    Mission(
      id: 4,
      mosque: Mosque(name: 'Mosquée El Hidaya', address: 'Bir Mourad Rais',  isApproved: true),
      status: 'pending',
      driver: User(firstName: 'Ali', lastName: 'Zerrouki', password: ''),
    ),
  ];
  // static final List<AdminCompletedMission> mockCompletedMissions = [
  //   AdminCompletedMission(
  //     driverName: 'أحمد بن عيسى',
  //     driverPhone: '0555123456',
  //     mosqueName: 'مسجد النور',
  //     amount: 15000.0,
  //     collectionDate: DateTime(2025, 5, 10),
  //   ),
  //   AdminCompletedMission(
  //     driverName: 'سامي بوقطاية',
  //     driverPhone: '0666789012',
  //     mosqueName: 'مسجد الفرقان',
  //     amount: 9800.0,
  //     collectionDate: DateTime(2025, 5, 14),
  //   ),
  //   AdminCompletedMission(
  //     driverName: 'كمال لبيض',
  //     driverPhone: '0777456789',
  //     mosqueName: 'مسجد التقوى',
  //     amount: 17300.0,
  //     collectionDate: DateTime(2025, 5, 17),
  //   ),
  //   AdminCompletedMission(
  //     driverName: 'ياسين شريف',
  //     driverPhone: '0555432109',
  //     mosqueName: 'مسجد الفتح',
  //     amount: 14200.0,
  //     collectionDate: DateTime(2025, 5, 20),
  //   ),
  // ];


  static void showSnackBar(BuildContext context, IconData icon, String barText,
      Color barColor, Duration duration) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  barText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: barColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: duration,
        ),
      );
  }

  static String formatDistanceAndDuration(String rawDistance, String rawDuration) {
    // Clean distance and remove any decimal or Arabic text
    final numericDistance = double.tryParse(
      rawDistance.replaceAll(RegExp(r'[^\d.]'), ''),
    )?.toStringAsFixed(0) ?? '?';

    // Clean duration and convert to int
    final totalMinutes = int.tryParse(
      rawDuration.replaceAll(RegExp(r'[^\d]'), ''),
    ) ?? 0;

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    final durationStr = [
      if (hours > 0) '${hours}h',
      if (minutes > 0) '${minutes} min',
    ].join(' ');

    return '$numericDistance km, $durationStr';
  }

}