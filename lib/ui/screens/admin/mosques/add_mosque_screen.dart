import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:maps_app/data/models/mosque.dart';
import 'package:maps_app/main.dart';
import 'package:maps_app/utils/formz/address.dart';
import 'package:maps_app/utils/formz/latitude.dart';
import 'package:maps_app/utils/formz/longitude.dart';
import '../../../../data/models/user.dart';
import '../../../../routing/app_routes.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/formz/username.dart';
import '../../../bloc/authentication/authentication_bloc.dart';
import '../../../bloc/authentication/authentication_event.dart';
import '../../../bloc/mosque/add_mosque_cubit.dart';
import '../../../bloc/mosque/add_mosque_state.dart';
import '../../../widgets/custom_text_input.dart';

class AddMosqueScreen extends StatelessWidget {
  final int? mosqueId;

  const AddMosqueScreen({super.key, this.mosqueId});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // prevent default pop
      onPopInvokedWithResult: (didPop,r) {
        if (!didPop) {
         context.pushReplacementNamed(AppRoutes.Home);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            // Customize the back button icon
            onPressed: () {
              context.pushReplacementNamed(AppRoutes.Home);
            },
          ),
          actions: mosqueId == null ? null : [
            IconButton(
                onPressed: () {
                  //deletion dialogue
                  _showDeleteUserAlert(mosqueId!, context);
                },
                icon: Icon(
                  Icons.playlist_remove_sharp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
          ],
        ),
        body: _AddMosquePage(mosqueId: mosqueId,),
      ),
    );
  }

  void _showDeleteUserAlert(int mosqueId, BuildContext userContext) {
    final theme = Theme.of(userContext);
    final mosqueName = userContext.read<AddMosqueCubit>().state.name.value;
    showDialog(
      context: userContext, // Use the context from the outer scope
      builder: (BuildContext dialogContext) {
        // Renamed to avoid confusion with outer context
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Rounded corners
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.redAccent), // Warning icon
              SizedBox(width: 8),
              Text(
                  'تأكيد الحذف',
                  style: theme.textTheme.titleLarge)
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min, // To wrap content
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ستقوم بحذف المسجد ${mosqueName}. هل تريد المتابعة ؟ ',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
            ],
          ),
          actionsPadding:
          const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Use dialogContext here
              },
              child: const Text(
                'إلغاء',
                style:
                TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                userContext
                    .read<AddMosqueCubit>().deleteMosque(mosqueId);

                userContext.pushReplacementNamed(AppRoutes.Home);
                dialogContext.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded button
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              icon: const Icon(Icons.delete, color: Colors.white),
              label: const Text(
                'حذف',
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AddMosquePage extends StatelessWidget {
  final int? mosqueId;

  const _AddMosquePage({super.key, this.mosqueId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: material.TextDirection.ltr,
      child: SingleChildScrollView(
        child: BlocListener<AddMosqueCubit, AddMosqueState>(
          listenWhen:
              (currState, newState) =>
                  currState.loadStatus != newState.loadStatus,
          listener: (context, state) {
            if (state.loadStatus == AddMosqueStatus.success) {
              context.pushReplacementNamed(AppRoutes.Home);
            } else if (state.loadStatus == AddMosqueStatus.failed) {
              Constants.showSnackBar(
                context,
                Icons.error_outline,
                state.errorMessage ?? 'حدث خطأ في عملية حفض المعلومات',
                theme.colorScheme.error,
                const Duration(seconds: 5),
              );
            } else if (state.loadStatus == AddMosqueStatus.tokenExpired) {
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15.0, left: 15, right: 15),
                child: Text(
                  'معلومات المسجد',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[700],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 25,
                      right: 25,
                      bottom: 25,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildLabel('اسم المسجد', theme),
                        _NameInput(),
                        const SizedBox(height: 20),
                        _buildLabel('عنوان المسجد', theme),
                        _AddressInput(),
                        const SizedBox(height: 20),
                        _buildLabel('امام المسجد', theme),
                        ImamSelector(),
                        const SizedBox(height: 20),
                        _buildLabel('خط العرض', theme),
                        _LatitudeInput(),
                        const SizedBox(height: 20),
                        _buildLabel('خط الطول', theme),
                        _LongitudeInput(),
                        SizedBox(height: 20),
                        _buildLocationApprovalSection(context),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  SignUpButton(mosqueId: mosqueId),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String labelText, ThemeData theme) {
    return Text(labelText, style: theme.textTheme.titleMedium);
  }

  Widget _buildLocationApprovalSection(BuildContext context) {
    final state = context.watch<AddMosqueCubit>().state;
    logger.log(Logger.level, 'is approved ...${state.isApproved}');
    logger.log(Logger.level, 'imam lat ...${state.imam.lat}, imam lng ...${state.imam.lng}');
    if (state.isApproved || (state.latitude.value.isEmpty && state.longitude.value.isEmpty)) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red[800]),
                  const SizedBox(width: 8),
                  Text(
                    "الموقع غير معتمد، تأكد من صحته",
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: Colors.red[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              //const SizedBox(height: 12),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      side: BorderSide(color: theme.colorScheme.primary),
                    ),
                    onPressed: () {
                      final lat = double.tryParse(state.latitude.value);
                      final lng = double.tryParse(state.longitude.value);
                      if (lat != null && lng != null) {
                        context.pushNamed(
                          AppRoutes.MapPreview,
                          extra: LatLng(lat, lng),
                        );
                      }
                    },
                    child: Text(
                      "عرض على الخريطة",
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    onPressed: () {
                      context.read<AddMosqueCubit>().approveLocation();
                    },
                    child: const Text("اعتماد الموقع"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _NameInput extends StatelessWidget {
  _NameInput();

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.text = context.read<AddMosqueCubit>().state.name.value;
    return BlocBuilder<AddMosqueCubit, AddMosqueState>(
      buildWhen: (prevState, currState) {
        return prevState.name != currState.name;
      },
      builder: (context, state) {
        final errorMessage =
            state.name.displayError == UsernameValidationError.invalid
                ? 'اسم غير صالح'
                : 'يجب ان يكون الاسم مكون من حرفين على الاقل';
        return CustomTextInput(
          hintText: 'ادخل الاسم',
          value: state.name.value,
          icon: Icons.mosque_outlined,
          onChanged:
              (val) => context.read<AddMosqueCubit>().mosqueNameChanged(val),
          errorText: state.name.displayError != null ? errorMessage : null,
        );
      },
    );
  }
}

class _AddressInput extends StatelessWidget {
  _AddressInput();

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.text = context.read<AddMosqueCubit>().state.address.value;
    return BlocBuilder<AddMosqueCubit, AddMosqueState>(
      buildWhen: (prevState, currState) {
        return prevState.address != currState.address;
      },
      builder: (context, state) {
        final errorMessage =
            state.address.displayError == AddressValidationError.invalid
                ? 'عنوان المسجد غير صالح'
                : 'يجب ان يكون عنوان المسجد مكون من حرفين على الاقل';
        return CustomTextInput(
          hintText: 'ادخل عنوان المسجد',
          value: state.address.value,
          icon: Icons.location_city_sharp,
          onChanged:
              (val) => context.read<AddMosqueCubit>().addressChanged(val),
          errorText: state.address.displayError != null ? errorMessage : null,
        );
      },
    );
  }
}

class _LatitudeInput extends StatelessWidget {
  _LatitudeInput();

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.text = context.read<AddMosqueCubit>().state.latitude.value;
    return BlocBuilder<AddMosqueCubit, AddMosqueState>(
      buildWhen: (prevState, currState) {
        return prevState.latitude != currState.latitude;
      },
      builder: (context, state) {
        final errorMessage =
            state.latitude.displayError == LatitudeValidationError.invalid
                ? 'خط العرض غير صالح'
                : 'يجب ان يكون خط العرض بين -90 و 90  مثال: 36.756061';
        return CustomTextInput(
          hintText: 'ادخل خط العرض',
          value: state.latitude.value,
          icon: Icons.add_location_alt_outlined,
          onChanged:
              (val) => context.read<AddMosqueCubit>().latitudeChanged(val),
          errorText: state.latitude.displayError != null ? errorMessage : null,
        );
      },
    );
  }
}

class _LongitudeInput extends StatelessWidget {
  _LongitudeInput();

  @override
  Widget build(BuildContext context) {
    _controller.text = context.read<AddMosqueCubit>().state.longitude.value;
    return BlocBuilder<AddMosqueCubit, AddMosqueState>(
      buildWhen: (prevState, currState) {
        return prevState.longitude != currState.longitude;
      },
      builder: (context, state) {
        final errorMessage =
            state.longitude.displayError == LongitudeValidationError.invalid
                ? 'خط الطول غير صالح'
                : ' يجب ان يكون خط الطول  بين -180 و 180 مثال: 3.442273';
        return CustomTextInput(
          hintText: 'ادخل خط الطول',
          value: state.longitude.value,
          icon: Icons.add_location_alt_outlined,
          onChanged:
              (val) => context.read<AddMosqueCubit>().longitudeChanged(val),
          errorText: state.longitude.displayError != null ? errorMessage : null,
        );
      },
    );
  }

  final TextEditingController _controller = TextEditingController();
}

class ImamSelector extends StatefulWidget {
  const ImamSelector({super.key});

  @override
  State<ImamSelector> createState() => _ImamSelectorState();
}

class _ImamSelectorState extends State<ImamSelector> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void _openImamSelectionDialog() async {
    final result = await showModalBottomSheet<User>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: true,
      builder:
          (_) => SizedBox(
            height: 500,
            child: BlocListener<AddMosqueCubit, AddMosqueState>(

              listener: (BuildContext context, state) {
                if(state.loadStatus == AddMosqueStatus.failed){
                  Constants.showSnackBar(
                    context,
                    Icons.error_outline,
                    state.errorMessage ?? 'حدث خطأ في عملية حفض المعلومات',
                    Colors.redAccent,
                    const Duration(seconds: 5),
                  );
                }else if(state.loadStatus == AddMosqueStatus.tokenExpired){
                  context.read<AuthenticationBloc>().add(AdminLogoutRequested());
                }
              },
              child: const ImamsList(),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocSelector<AddMosqueCubit, AddMosqueState, User>(
      selector: (state) => state.imam,
      builder: (context, selectedImam) {
        final fullName =
            selectedImam != User.empty
                ? '${selectedImam.firstName} ${selectedImam.lastName}'
                : '';

        // Update text if needed
        if (_controller.text != fullName) {
          _controller.text = fullName;
          _controller.selection = TextSelection.collapsed(
            offset: _controller.text.length,
          );
        }

        return GestureDetector(
          onTap: _openImamSelectionDialog,
          child: AbsorbPointer(
            child: TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "اختر الإمام",
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.primary,
                ),
                suffixIcon: Icon(Icons.arrow_drop_down_outlined),
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.blueGrey[700]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class SignUpButton extends StatelessWidget {
  final int? mosqueId;

  const SignUpButton({super.key, required this.mosqueId});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final state = context.watch<AddMosqueCubit>().state;

        return Padding(
          padding: const EdgeInsets.only(bottom:20.0),
          child: ElevatedButton(
            onPressed: () {
              if (state.isValid) {
                logger.log(Logger.level, 'logging isValid:${state.isValid}, isApproved:${state.isApproved}');

                if (mosqueId == null) {
                  context.read<AddMosqueCubit>().addMosque(
                    Mosque(
                      name: state.name.value,
                      address: state.address.value,
                      imam: state.imam,
                      lat: state.latitude.value,
                      ling: state.longitude.value,
                    ),
                  );
                  //context.pushReplacementNamed(AppRoutes.Home);
                } else {
                  // update current mosque
                  logger.log(Logger.level, 'updating the current mosque with id ${mosqueId}');
                  context.read<AddMosqueCubit>().updateMosque(
                    Mosque(
                      id: mosqueId,
                      name: state.name.value,
                      address: state.address.value,
                      imam: state.imam,
                      lat: state.latitude.value,
                      ling: state.longitude.value,
                    ),
                  );
                }
              } else {
                logger.log(Logger.level, 'logging isValid:${state.isValid}, isApproved:${state.isApproved}');
                Constants.showSnackBar(
                  context,
                  Icons.error_outline,
                  'معلومات خاطئة',
                  Theme.of(context).colorScheme.error,
                  const Duration(seconds: 5),
                );
              }
            },
            style: ButtonStyle(
              fixedSize: WidgetStateProperty.all<Size>(const Size(300.0, 48.0)),
              backgroundColor: WidgetStateProperty.all<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              elevation: WidgetStateProperty.all(5),
              shadowColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
            ),
            child:
                state.loadStatus == AddMosqueStatus.loading
                    ? CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                    : const Text(
                      'تأكيد',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        );
      },
    );
  }
}

class ImamsList extends StatefulWidget {


  const ImamsList({
    super.key,
  });

  @override
  State<ImamsList> createState() => _ImamsListState();
}

class _ImamsListState extends State<ImamsList> {
  @override
  void initState() {
    context.read<AddMosqueCubit>().getImamsWithoutCoordinates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AddMosqueCubit, AddMosqueState>(
      builder: (context, state) {
        if (state.loadStatus == AddMosqueStatus.loading) {
          return SpinKitThreeBounce(
            color: theme.colorScheme.secondary,
            size: 40.0,
          );
        }

        var imams = state.imamsList;
       // final imams = List.of(Constants.mockUsers);

        return imams.isNotEmpty
            ? ListView.builder(
          itemCount: imams.length,
          itemBuilder: (context, index) {
            return ImamLisItem(imam: imams[index]);
          },
        )
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/empty_image.png', height: 100, width: 100),
              Text(
                'لا يوجد مستخدمين حاليا',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ImamLisItem extends StatelessWidget {
  final User imam;

  const ImamLisItem({
    Key? key,
    required this.imam,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final username = '${imam.firstName} ${imam.lastName}';
    return Card(
      elevation: 4,
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
            context.read<AddMosqueCubit>().imamChanged(imam);
            context.pop();
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  username.isNotEmpty
                      ? username.substring(0, 1).toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  username,
                  style:theme.textTheme.titleLarge,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// class ImamSelectionDialog extends StatefulWidget {
//   const ImamSelectionDialog({super.key});
//
//   @override
//   State<ImamSelectionDialog> createState() => _ImamSelectionDialogState();
// }
//
// class _ImamSelectionDialogState extends State<ImamSelectionDialog> {
//   User? selected;
//   late Future<List<User>> _futureImams;
//
//   @override
//   void initState() {
//     super.initState();
//     _futureImams = context.read<AddMosqueCubit>().getImamList(); // Call cubit here
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: FutureBuilder<List<User>>(
//           future: _futureImams,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return const Center(child: Text('لا يوجد أئمة متاحون'));
//             }
//
//             final imams = snapshot.data!;
//             return Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   'اختر الإمام',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//                 Expanded(
//                   child: ListView.separated(
//                     itemCount: imams.length,
//                     separatorBuilder: (_, __) => const Divider(),
//                     itemBuilder: (_, index) {
//                       final imam = imams[index];
//                       final fullName = '${imam.firstName} ${imam.lastName}';
//                       final isSelected = selected?.id == imam.id;
//
//                       return ListTile(
//                         title: Text(fullName),
//                         trailing: isSelected
//                             ? const Icon(Icons.check_circle, color: Colors.green)
//                             : null,
//                         onTap: () {
//                           setState(() {
//                             selected = imam;
//                           });
//                         },
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: selected != null
//                       ? () => Navigator.pop(context, selected)
//                       : null,
//                   child: const Text('تأكيد الاختيار'),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
