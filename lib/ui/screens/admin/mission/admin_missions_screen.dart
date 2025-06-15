import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:logger/logger.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:maps_app/main.dart';
import 'package:maps_app/ui/widgets/empty_list_widget.dart';
import 'package:maps_app/ui/widgets/role_chips.dart';
import 'package:maps_app/utils/constants.dart';

import '../../../../data/models/mission.dart';
import '../../../../data/models/user.dart';
import '../../../bloc/missions/mission_list_cubit.dart';
import '../../../bloc/missions/missions_list_state.dart';
import '../../../widgets/custom_search_bar.dart';

class AdminMissionsScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          _SearchBar(),
          FilterChips(
              chipLabels: Constants.missionStatusList,
              initialSelected: Constants.missionStatusList[0],
              onSelected: (role){
                logger.log(Logger.level, role);
                context.read<MissionsListCubit>().getMissions(statusFilter: _getMissionStatus(role));
                context.read<MissionsListCubit>().clearSearchQuery();
              }
          ),
          DaysAgoFilterChips(
            presetDays: const [0, 7, 30],
            initialSelected: 0,
            onSelected: (days) {
              context.read<MissionsListCubit>().getMissions(daysAgoFilter: days);
            },),
          const SizedBox(height: 15,),
          Expanded(child: _MissionsList()),
        ],
      ),
    );
  }
  String _getMissionStatus(String arabicStatus) {
    switch (arabicStatus.trim()) {
      case 'متاحة':
        return 'AVAILABLE';
      case 'قيد التنفيذ':
        return 'PENDING';
      case 'انتهت':
        return 'COMPLETED';
      default:
        throw ArgumentError('Invalid status: $arabicStatus');
    }
  }
}

class DaysAgoFilterChips extends StatefulWidget {
  final List<int> presetDays;
  final ValueChanged<int> onSelected;
  final int? initialSelected;

  const DaysAgoFilterChips({
    super.key,
    required this.presetDays,
    required this.onSelected,
    this.initialSelected,
  });

  @override
  State<DaysAgoFilterChips> createState() => _DaysAgoFilterChipsState();
}

class _DaysAgoFilterChipsState extends State<DaysAgoFilterChips> {
  late int selectedDays;

  @override
  void initState() {
    super.initState();
    selectedDays = widget.initialSelected ?? widget.presetDays.first;
  }

  void _showCustomInputDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('أدخل عدد الأيام'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'من 0 إلى 365'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final input = int.tryParse(controller.text);
                if (input != null && input >= 0 && input <= 365) {
                  setState(() {
                    selectedDays = input;
                  });
                  widget.onSelected(input);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('يرجى إدخال رقم بين 0 و365')),
                  );
                }
              },
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: widget.presetDays.length + 1, // +1 for custom
          separatorBuilder: (_, __) => const SizedBox(width: 5),
          itemBuilder: (_, index) {
            if (index < widget.presetDays.length) {
              final days = widget.presetDays[index];
              return InputChip(
                label: Text(days == 0 ? 'اليوم':'آخر $days يوم'),
                showCheckmark: true,
                selected: selectedDays == days,
                onSelected: (_) {
                  setState(() {
                    selectedDays = days;
                  });
                  widget.onSelected(days);
                },
                selectedColor: theme.colorScheme.primary,
                checkmarkColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            } else {
              return InputChip(
                label: const Text('تحديد عدد الأيام'),
                avatar: const Icon(Icons.edit_calendar),
                selected: !widget.presetDays.contains(selectedDays),
                onSelected: (_) => _showCustomInputDialog(),
                selectedColor: theme.colorScheme.primary,
                checkmarkColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }
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
    context.read<MissionsListCubit>().getMissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<MissionsListCubit,MissionsListState>(
      builder: (context, state) {
        if(state.status == MissionsListStatus.loading){
          return SpinKitThreeBounce(
            color: theme.colorScheme.secondary,
            size: 40.0,
          );
        }else{
          final missions = state.searchQuery.isEmpty ? state.missionsList : state.searchMissionsList;
          //final missions = Constants.mockMissions;
          if(missions.isEmpty && _isFriday()){
            return ResetMissionsWidget(onReset: (){
              context.read<MissionsListCubit>().initMissions();
            });
          }
          return missions.isEmpty ? EmptyListWidget(emptyMessage: 'لا يوجد مهام حاليا'): ListView.builder(
            itemCount: missions.length,
            itemBuilder: (context, index) {
              return MissionItem(mission: missions[index],);
            },
          );
        }

      }
    );
  }
  bool _isFriday(){
    final datetime = DateTime.now();
    return datetime.weekday == DateTime.sunday;
  }
}

class MissionItem extends StatelessWidget {
  final Mission mission;

  const MissionItem({super.key, required this.mission});

  Color _statusColor(String status, BuildContext context) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'available':
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primary,
              child: Icon(Icons.mosque_outlined, color: theme.colorScheme.onPrimary),
            ),
            const SizedBox(width: 16),

            // Main Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.mosque.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                 if(mission.driver != User.empty)...[
                   Row(
                     children: [
                       const Icon(Icons.person, size: 18, color: Colors.grey),
                       const SizedBox(width: 6),
                       Text(
                         '${mission.driver.firstName} ${mission.driver.lastName}',
                         style: theme.textTheme.bodySmall,
                       ),
                     ],
                   )
                 ]
                 ,
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(mission.status, context).withOpacity(0.1),
                      border: Border.all(color: _statusColor(mission.status, context)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusLabel(mission.status),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _statusColor(mission.status, context),
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
    );
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'في الانتظار';
      case 'completed':
        return 'تمت المهمة';
      case 'available':
      default:
        return 'متاحة';
    }
  }
}
class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MissionsListCubit, MissionsListState>(
      buildWhen: (prev, curr) => prev.searchQuery != curr.searchQuery,
      builder: (context, state) {
        return CustomSearchBar(
          searchText: state.searchQuery,
          onChanged: (value) => context.read<MissionsListCubit>().searchMission(value),
          onClear: () => context.read<MissionsListCubit>().searchMission(''),
          hintText: 'البحث عن مهمة',
          prefixIcon: Icons.mosque_outlined,
        );
      },
    );
  }
}
class ResetMissionsWidget extends StatelessWidget {
  final VoidCallback onReset;

  const ResetMissionsWidget({super.key, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.refreshCw, size: 28, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    'إعادة تعيين المهام الأسبوعية',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                'اضغط على الزر أدناه لتحديث المهام لجميع المساجد لهذا الأسبوع.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                ),
                icon:  Icon(LucideIcons.refreshCcw, color: Theme.of(context).colorScheme.onPrimary),
                label: Text(
                  'إعادة التعيين',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


