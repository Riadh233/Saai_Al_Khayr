import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:maps_app/data/models/driver_mission.dart';
import 'package:maps_app/main.dart';
import 'package:maps_app/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/location_cubit/location_cubit.dart';
import '../bloc/location_cubit/location_state.dart';
import '../bloc/mosque/mosque_list_cubit.dart';
import '../bloc/mosque/mosque_list_state.dart';

class MapScreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: BlocConsumer<UserLocationCubit, UserLocationState>(
        listenWhen: (prevState, currState) {
          return currState.status != prevState.status;
        },
        listener: (context, state) {
          logger.log(Logger.level, 'location state status: ${state.status}');
          if (state.status == UserLocationStatus.loading) {
            Constants.showSnackBar(
              context,
              LucideIcons.locate,
              'جاري تحميل موقعك الحالي',
              Colors.green,
              Duration(minutes: 1),
            );
          }
          if (state.status == UserLocationStatus.success) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: _MapScreen(),
            floatingActionButton:state.pickedMission != null ?  FloatingActionButton.extended(
              onPressed: () {
                _showNavigationBottomSheet(context, state.pickedMission!);
              },
              backgroundColor: theme.colorScheme.secondary,
              label: Text(
                'بدء التنقل',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              icon: const Icon(LucideIcons.navigation, color: Colors.white),
            ) : null,
          );
        },
      ),
    );
  }
  void _showNavigationBottomSheet(BuildContext context, MissionCoordinates pickedMission) {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'أنت على وشك بدء التنقل إلى وجهتك باستخدام خرائط Google',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // Mosque name
              Row(
                children: [
                  const Icon(Icons.mosque, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pickedMission.mosqueName!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Address
              if (pickedMission.mosqueAddress != null && pickedMission.mosqueAddress!.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      LucideIcons.mapPin,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${pickedMission.mosqueAddress}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),

              // Distance
              if (pickedMission.distance != null)
                Row(
                  children: [
                    Icon(
                      Icons.car_crash_outlined,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${pickedMission.distance} , ${pickedMission.duration}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      icon: const Icon(LucideIcons.x),
                      label: const Text('إلغاء'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      icon: const Icon(LucideIcons.navigation),
                      label: const Text('بدء التنقل'),
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<UserLocationCubit>().openGoogleMaps();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MapScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MapScreenState();
}

class _MapScreenState extends State<_MapScreen> {
  @override
  void initState() {
    context.read<MosqueListCubit>().getAllMosques();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserLocationCubit, UserLocationState>(
      builder: (context, locationState) {
        final userLocation = LatLng(
          locationState.latitude,
          locationState.longitude,
        );
        final shortestPath = locationState.pickedMission?.shortestPath;
        return Scaffold(
          body: FlutterMap(
            options: MapOptions(
              initialCenter:
                  userLocation == LatLng(-1, -1)
                      ? LatLng(36.7598, 3.4723)
                      : userLocation,
              initialZoom: 12,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap:
                        () => launchUrl(
                          Uri.parse('https://openstreetmap.org/copyright'),
                        ), // (external)
                  ),
                ],
              ),
              //mosque list
              BlocBuilder<MosqueListCubit,MosqueListState>(
                buildWhen: (prev, curr){
                  return prev.mosquesList != curr.mosquesList;
                },
                builder: (context, state) {
                  return MarkerLayer(
                    markers:
                        state.mosquesList.where((mosque) => mosque.lat != null && mosque.ling != null).map((mosque) {
                          final lat = double.parse(mosque.lat!);
                          final lng = double.parse(mosque.ling!);
                          return Marker(
                            point: LatLng(lat ,lng),
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              onTap: () {
                                //_showNavigationBottomSheet(context, locationState.pickedMission!);
                                //enable admin to put the clicked mosque as available for collecting charities
                                if (userLocation != LatLng(-1, -1)) {
                                  logger.log(
                                    Logger.level,
                                    '${userLocation.longitude},${userLocation.latitude}...${mosque.lat},${mosque.ling}',
                                  );
                                }
                              },
                              child: const Icon(Icons.mosque,size: 18, color: Colors.red),
                            ),
                          );
                        }).toList(),
                  );
                }
              ),
              if (userLocation != LatLng(-1, -1))
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),

              // ➰ Draw polyline when route is ready
              if (shortestPath != null && shortestPath.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: shortestPath,
                      color: Colors.blue,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),


            ],
          ),
        );
      },
    );
  }

  void _showNavigationBottomSheet(BuildContext context, MissionCoordinates pickedMission) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.navigation,
                color: Theme.of(context).colorScheme.primary,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                'التنقل إلى هذا الموقع: ${pickedMission.mosqueName}',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<UserLocationCubit>().openGoogleMaps();
                      },
                      icon: const Icon(LucideIcons.navigation, size: 20),
                      label: const Text('بدء التنقل'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
