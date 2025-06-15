import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:maps_app/data/models/completed_mission.dart';
import 'package:maps_app/ui/widgets/custom_text_input.dart';
import 'package:maps_app/ui/widgets/empty_list_widget.dart';
import 'package:maps_app/utils/constants.dart';
import 'package:maps_app/utils/formz/arabic_money.dart';
import 'package:maps_app/utils/formz/dzd_money.dart';
import '../../bloc/authentication/authentication_bloc.dart';
import '../../bloc/authentication/authentication_event.dart';
import '../../bloc/imam/imam_missions_cubit.dart';
import '../../bloc/imam/imam_missions_state.dart';

class ImamMissionsScreen extends StatelessWidget {
  const ImamMissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<ImamMissionsCubit, ImamMissionsState>(
      listenWhen: (prevState, currState) {
        return prevState.status != currState.status;
      },
      listener: (context, state) {
        if (state.status == ImamMissionsStatus.tokenExpired) {
          context.read<AuthenticationBloc>().add(AdminLogoutRequested());
          Constants.showSnackBar(
            context,
            Icons.error_outline,
            state.errorMessage!,
            Colors.redAccent,
            const Duration(seconds: 2),
          );
        }else if(state.status == ImamMissionsStatus.amountSuccess){
          Constants.showSnackBar(
            context,
            Icons.library_add_check_outlined,
            'تم اضافة المبلغ بنجاح',
            Colors.green,
            const Duration(seconds: 2),
          );
        }else if (state.status == ImamMissionsStatus.failed){
          Constants.showSnackBar(
            context,
            Icons.error_outline,
            state.errorMessage!,
            Colors.redAccent,
            const Duration(seconds: 4),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(
            'قائمة التبرعات',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.surface,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(children: [Expanded(child: _MissionsList())]),
      ),
    );
  }
}

class _MissionsList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MissionsListState();
}

class _MissionsListState extends State<_MissionsList> {
  @override
  void initState() {
    context.read<ImamMissionsCubit>().getActiveMission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ImamMissionsCubit, ImamMissionsState>(
      builder: (context, state) {
        if (state.status == ImamMissionsStatus.loading) {
          return SpinKitThreeBounce(
            color: theme.colorScheme.secondary,
            size: 40.0,
          );
        }else{
          final mission = state.currentMission;
          // final mission = Constants.mockMissions.first;
          return mission == null
              ? EmptyListWidget(emptyMessage:'لا توجد عملية جمع التبرعات لهذا المسجد')
              : ListView(
            shrinkWrap: true,
            children: List.generate(1, (i) {
              return _missionListItem(mission, context);
            }),
          );
        }
      },
    );
  }

  Widget _missionListItem(CompletedMission mission, BuildContext context) {
    final theme = Theme.of(context);
    final fullName = '${mission.driver.firstName} ${mission.driver.lastName}';
    final phoneNumber = mission.driver.number;
    final carNumber = mission.driver.carNumber;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          // handle tap if needed
          _showAmountInputDialogue(context: context, amount: mission.amount,amountArabic: mission.amountArabic);
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primary,
                child: Icon(
                  Icons.mosque_outlined,
                  color: theme.colorScheme.onPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.car_crash_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            fullName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (phoneNumber != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 18, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              phoneNumber,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (carNumber != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.car_rental, size: 18, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(carNumber, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          mission.alreadyAdded
                              ? Icons.check_circle
                              : Icons.warning_amber_rounded,
                          size: 18,
                          color: mission.alreadyAdded ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            mission.alreadyAdded
                                ? 'تمت إضافة المبلغ بنجاح'
                                : 'لم يتم تحديد المبلغ المحصل من المال',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: mission.alreadyAdded ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAmountInputDialogue(
      {required BuildContext context, String? amount, String? amountArabic}) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder:
          (ctx) => BlocBuilder<ImamMissionsCubit, ImamMissionsState>(
            builder: (context, state) {
              final errorMessage =
                  state.amount.displayError == DzdAmountValidationError.invalid
                      ? 'المبلغ غير صالح'
                      : 'يجب ان يكون المبلغ مكون من رقمين على الاقل';
              final arabicAmountMessage =
                  state.arabicAmount.displayError ==
                          ArabicAmountValidationError.invalid
                      ? 'المبلغ غير صالح'
                      : 'يجب ان يكون المبلغ مكون من حرفين على الاقل';
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(
                      Icons.fact_check_outlined,
                      size: 28,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'إدخال مبلغ التبرعات',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                content: SizedBox(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomTextInput(
                        hintText: 'المبلغ بالدينار (DZD)',
                        value: state.amount.value,
                        errorText:
                            (state.amount.displayError != null)
                                ? errorMessage
                                : null,
                        onChanged: (value) {
                          context.read<ImamMissionsCubit>().validateAmount(
                            value,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextInput(
                        hintText: 'المبلغ باالحروف العربية (اختياري)',
                        value: state.arabicAmount.value,
                        errorText:
                            (state.arabicAmount.displayError != null)
                                ? arabicAmountMessage
                                : null,
                        onChanged: (value) {
                          context
                              .read<ImamMissionsCubit>()
                              .validateArabicAmount(value);
                        },
                      ),
                    ],
                  ),
                ),
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
                      if (state.isValid) {
                        if(amount != '0' || amountArabic != null){
                          context.read<ImamMissionsCubit>().modifyMoneyForMission();
                        }
                        context.read<ImamMissionsCubit>().addMoneyToMission();
                        Navigator.of(context).pop();
                      }
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
              );
            },
          ),
    );
  }
}
