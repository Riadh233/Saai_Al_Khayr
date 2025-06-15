import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:logger/logger.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:maps_app/data/models/Imam.dart';
import 'package:maps_app/main.dart';
import '../../../utils/constants.dart';
import '../../bloc/imam/imam_cubit.dart';
import '../../bloc/imam/imam_state.dart';
import '../../bloc/location_cubit/location_cubit.dart';
import '../../bloc/location_cubit/location_state.dart';

class ImamScreen extends StatelessWidget {
  const ImamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: material.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(
            'الملف الشخصي',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.surface,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),

        body: BlocListener<UserLocationCubit, UserLocationState>(
          listenWhen: (prevState, currState) {
            return prevState.status != currState.status;
          },
          listener: (BuildContext context, state) {
            if (state.status == UserLocationStatus.loading) {
              Constants.showSnackBar(
                context,
                LucideIcons.locate,
                '...جاري تحميل موقعك الحالي',
                Colors.green,
                Duration(minutes: 1),
              );
            } else if (state.status == UserLocationStatus.success) {
              Constants.showSnackBar(
                context,
                LucideIcons.locateFixed,
                'تم تحميل موقعك بنجاح',
                Colors.green,
                Duration(seconds: 2),
              );
              context.read<ImamCubit>().updateMosqueLocation(
                state.latitude,
                state.longitude,
              );
            } else if (state.status == UserLocationStatus.failure) {
              Constants.showSnackBar(
                context,
                Icons.error_outline,
                'حدث مشكل في العثور على موقعك',
                Colors.red,
                Duration(seconds: 5),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _ImamInfoPage(),
          ),
        ),
      ),
    );
  }
}

class _ImamInfoPage extends StatefulWidget {
  @override
  State<_ImamInfoPage> createState() => _ImamInfoPageState();
}

class _ImamInfoPageState extends State<_ImamInfoPage> {
  @override
  void initState() {
    context.read<ImamCubit>().getImamInfos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<ImamCubit, ImamState>(
      listenWhen: (prev, curr) {
        return prev.status != curr.status;
      },
      listener: (context, state) {
        if (state.status == ImamProfileStatus.failure) {
          Constants.showSnackBar(
            context,
            Icons.wifi_tethering_off,
           state.errorMessage!,
            Colors.redAccent,
            const Duration(seconds: 5),
          );
        }
      },
      child: BlocBuilder<ImamCubit, ImamState>(
        builder: (context, state) {
          logger.log(Logger.level, state.mosque.toString());
          if (state.status == ImamProfileStatus.loading) {
            return SpinKitThreeBounce(
              color: theme.colorScheme.secondary,
              size: 40.0,
            );
          } else {
            return Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'معلوماتك الشخصية',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.user,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(state.imamName, style: theme.textTheme.bodyLarge,),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.phone,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(state.imamNumber, style: theme.textTheme.bodyLarge,),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child:
                        state.mosque != null
                            ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'معلومات المسجد',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.mosque,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(state.mosque!.name, style: theme.textTheme.bodyLarge,),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, color: Colors.grey[700], size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        state.mosque!.address!,
                                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                if (state.mosque!.lat == null) ...[
                                  ElevatedButton.icon(
                                    icon: const Icon(
                                      LucideIcons.locateFixed,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    label: Text(
                                      'تعيين موقعي كموقع المسجد',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.white
                                      ),
                                    ),
                                    onPressed:
                                        () =>
                                            _showConfirmLocationDialog(context),
                                  ),
                                ]
                                else if (state.mosque!.lat != null &&
                                    state.mosque!.isApproved == false) ...[
                                  Row(
                                    children: [
                                      const Icon(
                                        LucideIcons.alertCircle,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'تم إرسال موقع المسجد بانتظار الموافقة من الإدارة.\nإذا طُلب منك تغييره، يمكنك إعادة تعيين الموقع.',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                              color: Colors.orange
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    icon: const Icon(LucideIcons.locateFixed),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    label: Text(
                                      'تغيير موقع المسجد',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(color: Colors.white),
                                    ),
                                    onPressed:
                                        () =>
                                        _showConfirmLocationDialog(context),
                                  ),
                                ],
                              ],
                            )
                            : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'معلومات المسجد',
                                  style: theme.textTheme.titleLarge,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      LucideIcons.alertCircle,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'لم يتم تعيين مسجد لك بعد.\nيرجى التواصل مع الإدارة.',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  void _showConfirmLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // يمنع الإغلاق بالضغط خارج النافذة
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(
                  LucideIcons.alertTriangle,
                  size: 28,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'تحذير: إجراء حساس',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.orange),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'هل أنت متأكد أنك تقف الآن داخل حدود المسجد؟',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 12),
                Text(
                  'سيتم استخدام موقعك الحالي كموقع رسمي للمسجد، ولا يمكن التراجع عن هذا الإجراء إلا من قبل الإدارة.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
                child: const Text('إلغاء'),
              ),
              ElevatedButton.icon(
                icon: const Icon(
                  LucideIcons.checkCircle,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<UserLocationCubit>().getCurrentLocation();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                label: const Text(
                  'نعم، أنا في المسجد',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
