import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:maps_app/data/models/driver_mission.dart';
import 'package:maps_app/main.dart';
import 'package:maps_app/ui/widgets/empty_list_widget.dart';
import 'package:maps_app/ui/widgets/role_chips.dart';
import 'package:maps_app/utils/constants.dart';
import '../../bloc/authentication/authentication_bloc.dart';
import '../../bloc/authentication/authentication_event.dart';
import '../../bloc/bottom_nav_cubit/bottom_nav_cubit.dart';
import '../../bloc/driver/missions/driver_missions_cubit.dart';
import '../../bloc/driver/missions/driver_missions_state.dart';
import '../../bloc/location_cubit/location_cubit.dart';
import '../../bloc/location_cubit/location_state.dart';

class DriverMissionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        title: Text(
          'قائمة المهمات',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).colorScheme.surface,
            fontSize: 20,
          ),
        ),
      ),
      body: BlocListener<DriverMissionsCubit, DriverMissionsState>(
        listenWhen: (prevState, currState) {
          return prevState.status != currState.status;
        },
        listener: (context, state) {
          if (state.status == DriverMissionsStatus.pickMissionSuccess) {
            //set destination
            logger.log(
              Level.error,
              'picked mission success ........................',
            );
            context.read<UserLocationCubit>().setPickedMission(
              state.pickedMission!,
            );
            context.read<BottomNavCubit>().selectedTabChanged(0);
          } else if (state.status == DriverMissionsStatus.pickMissionFailed) {
            Constants.showSnackBar(
              context,
              Icons.error_outline,
              'لا يمكنك اختيار مهمة جديدة قبل إكمال المهمة الحالية.',
              Colors.redAccent,
              const Duration(seconds: 2),
            );
          } else if (state.status ==
              DriverMissionsStatus.missionCanceledSuccess) {
            Constants.showSnackBar(
              context,
              Icons.library_add_check,
              'تم الغاء المهمة بنجاح',
              Colors.green,
              const Duration(seconds: 2),
            );
          } else if (state.status == DriverMissionsStatus.tokenExpired) {
            context.read<AuthenticationBloc>().add(AdminLogoutRequested());
            Constants.showSnackBar(
              context,
              Icons.error_outline,
              state.errorMessage!,
              Colors.redAccent,
              const Duration(seconds: 2),
            );
          }
        },
        child: BlocBuilder<UserLocationCubit, UserLocationState>(
          builder: (BuildContext context, state) {
            final userLocation = LatLng(state.latitude, state.longitude);
            return RefreshIndicator(
              color: Theme.of(context).colorScheme.primary,
              onRefresh: () async {
                final filter =
                    context.read<DriverMissionsCubit>().state.selectedFilter;
                final locationState = context.read<UserLocationCubit>().state;
                final currLocation = LatLng(
                  locationState.latitude,
                  locationState.longitude,
                );

                if (filter == 'متاحة') {
                  context.read<DriverMissionsCubit>().getAvailableMissions(
                    currLocation,
                  );
                } else {
                  context.read<DriverMissionsCubit>().getPickedMission(
                    currLocation,
                  );
                }

                return Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  FilterChips(
                    chipLabels: Constants.userMissionStatus,
                    onSelected: (label) {
                      context.read<DriverMissionsCubit>().updateFilter(label);
                      final locationState =
                          context.read<UserLocationCubit>().state;
                      final currLocation = LatLng(
                        locationState.latitude,
                        locationState.longitude,
                      );

                      if (label == 'متاحة') {
                        context
                            .read<DriverMissionsCubit>()
                            .getAvailableMissions(currLocation);
                      } else {
                        context.read<DriverMissionsCubit>().getPickedMission(
                          currLocation,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height:
                        MediaQuery.of(context).size.height *
                        0.75, // أو أي ارتفاع مناسب
                    child: _MissionsList(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MissionsList extends StatefulWidget {
  @override
  State<_MissionsList> createState() => _MissionsListState();
}

class _MissionsListState extends State<_MissionsList> {
  @override
  void initState() {
    context.read<DriverMissionsCubit>().updateFilter('متاحة');
    final lat = context.read<UserLocationCubit>().state.latitude;
    final lng = context.read<UserLocationCubit>().state.longitude;
    final userLocation = LatLng(lat, lng);
    context.read<DriverMissionsCubit>().getAvailableMissions(userLocation);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<DriverMissionsCubit, DriverMissionsState>(
      builder: (context, state) {
        if (state.status == DriverMissionsStatus.loading) {
          return SpinKitThreeBounce(
            color: theme.colorScheme.secondary,
            size: 40.0,
          );
        } else {
          if (state.selectedFilter == 'متاحة') {
            final missions = state.missionsList;

            //  final missions = Constants.mockDriverMissions;
            return missions.isNotEmpty
                ? Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: ListView.builder(
                    itemCount: missions.length,
                    itemBuilder: (context, index) {
                      return _DriverMissionItem(missions[index], context);
                    },
                  ),
                )
                : EmptyListWidget(emptyMessage: 'لا توجد مهام حاليا',);
          } else {
            //show picked mission if any , else show empty widget
            if (state.status == DriverMissionsStatus.loading) {
              return SpinKitThreeBounce(
                color: theme.colorScheme.secondary,
                size: 40.0,
              );
            } else if (state.status ==
                DriverMissionsStatus.missionCanceledSuccess) {
              return EmptyListWidget(
                emptyMessage: 'لا توجد مهمة قيد التنفيذ حاليا',
              );
            } else {
              return state.pickedMission != null
                  ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: _PickedMissionItem(
                          state.pickedMission!,
                          context,
                        ),
                      ),
                    ],
                  )
                  : EmptyListWidget(
                    emptyMessage: 'لا توجد مهمة قيد التنفيذ حاليا',
                  );
            }
          }
        }
      },
    );
  }

  Widget _DriverMissionItem(DriverMission mission, BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          _showConfirmationDialog(
            context: context,
            mosqueName: mission.mosqueName,
            mosqueAddress: mission.mosqueAddress,
            time: mission.time,
            distance: mission.distance,
            titleText: 'تأكيد اختيار المهمة',
            contentText: 'هل أنت متأكد من اختيار هذه المهمة؟',
            color: Colors.green,
            icon: Icons.assignment_turned_in,
            onConfirm: () {
              final locationState = context.read<UserLocationCubit>().state;
              final currLocation = LatLng(
                locationState.latitude,
                locationState.longitude,
              );
              logger.log(
                Logger.level,
                'selected mission in dialogue  : ${mission.id}, ${currLocation}',
              );
              context.read<DriverMissionsCubit>().pickMission(
                mission,
                currLocation,
              );
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primary,
                child: Icon(
                  Icons.mosque_outlined,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 16),

              // Main Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mosque Name
                    Text(
                      mission.mosqueName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if(mission.mosqueAddress.isNotEmpty)...[
                      Row(
                        children: [
                          Icon(
                            LucideIcons.mapPin,
                            size: 18,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${mission.mosqueAddress}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        Icon(
                          Icons.car_crash_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${mission.distance} , ${mission.time}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Imam Name and Number
                    Row(
                      children: [
                        Icon(Icons.person, size: 18, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          'رقم الامام: ${mission.imamNumber}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Status Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'متاحة',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow
              const SizedBox(width: 8),
              Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _PickedMissionItem(MissionCoordinates mission, BuildContext context) {
    final theme = Theme.of(context);
    logger.log(Logger.level, 'distance : ${mission.distance}');
    logger.log(Logger.level, 'duration : ${mission.duration}');
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row with icon and mission info
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(
                      Icons.mosque_outlined,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          mission.mosqueName!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if(mission.mosqueAddress != null && mission.mosqueAddress!.isNotEmpty)...[
                          Row(
                            children: [
                              Icon(
                                LucideIcons.mapPin,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${mission.mosqueAddress}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                        Row(
                          children: [
                            Icon(
                              Icons.car_crash_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              Constants.formatDistanceAndDuration(mission.distance, mission.duration),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Row(
                        //   children: [
                        //     Icon(Icons.person, size: 18, color: Colors.grey),
                        //     const SizedBox(width: 6),
                        //     Text(
                        //       '${mission.imamName} (${mission.imamNumber})',
                        //       style: theme.textTheme.bodySmall,
                        //     ),
                        //   ],
                        // ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            border: Border.all(color: Colors.orange),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'قيد التنفيذ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: theme.colorScheme.primary,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<UserLocationCubit>().setPickedMission(
                        mission,
                      );
                      context.read<BottomNavCubit>().selectedTabChanged(0);
                    },
                    icon: const Icon(LucideIcons.navigation),
                    label: const Text("تنقل"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      _showCancelPickedMissionDialog(
                        context: context,
                        mosqueName: mission.mosqueName!,
                        time: mission.distance.toString(),
                        distance: mission.distance.toString(),
                        onConfirm: () {
                          context
                              .read<DriverMissionsCubit>()
                              .cancelPickedMission();
                        },
                      );
                    },
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text(
                      "إلغاء",
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showConfirmationDialog({
    required BuildContext context,
    required String mosqueName,
    required String mosqueAddress,
    required String time,
    required String distance,
    required IconData icon,
    required Color color,
    required String titleText,
    required String contentText,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(icon, size: 28, color: color),
                const SizedBox(width: 8),
                Text(
                  titleText,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contentText, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 12),
                Text(
                  'المسجد: $mosqueName',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if(mosqueAddress.isNotEmpty)...[
                  Row(
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${mosqueAddress}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.car_crash_outlined,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$distance, $time',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'إلغاء',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'تأكيد',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _showCancelPickedMissionDialog({
    required BuildContext context,
    required String mosqueName,
    required String time,
    required String distance,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.free_cancellation,
                  size: 28,
                  color: Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'تأكيد إلغاء المهمة',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'هل أنت متأكد من إلغاء هذه المهمة؟',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'المسجد: $mosqueName',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.car_crash_outlined,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${distance}, ${time} ',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'لا',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  onConfirm();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'تأكيد',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  //
  // Color _statusColor(String? status, BuildContext context) {
  //   switch (status) {
  //     case 'AVAILABLE':
  //       return Colors.green;
  //     case 'COMPLETED':
  //       return Colors.blue;
  //     case 'PENDING':
  //       return Colors.orange;
  //     default:
  //       return Colors.grey;
  //   }
  // }
  //
  // String _statusLabel(String? status) {
  //   switch (status) {
  //     case 'AVAILABLE':
  //       return 'متاحة';
  //     case 'COMPLETED':
  //       return 'منتهية';
  //     case 'PENDING':
  //       return 'قيد التنفيذ';
  //     default:
  //       return 'غير معروف';
  //   }
  // }
}
