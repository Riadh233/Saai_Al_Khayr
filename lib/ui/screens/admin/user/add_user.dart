import 'dart:ui' as material;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:maps_app/main.dart';
import 'package:maps_app/utils/formz/username.dart';

import '../../../../data/models/user.dart';
import '../../../../utils/get_it.dart';
import '../../../../routing/app_routes.dart';
import '../../../../utils/constants.dart';
import '../../../bloc/add_user/add_user_cubit.dart';
import '../../../bloc/add_user/add_user_state.dart';
import '../../../bloc/user_list/user_list_cubit.dart';
import '../../../bloc/user_list/user_list_state.dart';
import '../../../widgets/custom_text_input.dart';

class AddUserScreen extends StatelessWidget {
  final User user;
  final UserRole role;

  const AddUserScreen({super.key, required this.role, this.user = User.empty});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddUserCubit>(
      create: (context) {
        if (user == User.empty) {
          return getIt();
        } else {
          return getIt()..initialValues(user);
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
          elevation: 2,
        ),
        body: _SignUpForm(user: user, role: role),
      ),
    );
  }
}

class _SignUpForm extends StatelessWidget {
  final User user;
  final UserRole role;

  bool get isDriver => role == UserRole.driver;

  bool get isImam => role == UserRole.imam;

  bool get isAdmin => role == UserRole.admin;

  const _SignUpForm({super.key, required this.user, required this.role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<UserListCubit, UserListState>(
      listenWhen: (prevState, currState) {
        return prevState.status != currState.status &&
            (currState.status == UserListStatus.failed ||
                currState.status == UserListStatus.success);
      },
      listener: (context, state) {
        if (state.status == UserListStatus.failed) {
          Constants.showSnackBar(
            context,
            Icons.error_outline,
            state.errorMessage ?? 'حدث خطأ في عملية حفض المعلومات',
            theme.colorScheme.error,
            const Duration(seconds: 5),
          );
        }
        if (state.status == UserListStatus.success) {
          logger.log(Logger.level, 'finish adding user');
          context.pushReplacementNamed(AppRoutes.Home);
        }
      },
      child: Directionality(
        textDirection: material.TextDirection.ltr,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15.0, left: 15, right: 15),
                child: Text(
                  _getUserInfoTitle(role),
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
                        buildLabel('الاسم', theme),
                        _FirstNameInput(),
                        const SizedBox(height: 20),
                        buildLabel('اللقب', theme),
                        _LastNameInput(),
                        const SizedBox(height: 20),
                        buildLabel('رقم الهاتف', theme),
                        _PhoneNumberInput(),
                        if (isDriver) ...[
                          const SizedBox(height: 20),
                          buildLabel('رقم لوحة السيارة', theme),
                          _CarNumberInput(),
                        ],
                        const SizedBox(height: 20),
                        buildLabel('كلمة المرور', theme),
                        _PasswordInput(),
                        const SizedBox(height: 20),
                        buildLabel('تأكيد كلمة المرور', theme),
                        _ConfirmPasswordInput(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  SignUpButton(user: user, role: role,),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLabel(String labelText, ThemeData theme) {
    return Text(labelText, style: theme.textTheme.titleMedium);
  }

  String _getUserInfoTitle(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'معلومات المسؤول';

      case UserRole.driver:
        return 'معلومات السائق';

      case UserRole.imam:
        return 'معلومات الإمام';
    }
  }
}

class _FirstNameInput extends StatelessWidget {
  _FirstNameInput();

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.text = context.read<AddUserCubit>().state.firstName.value;
    return BlocBuilder<AddUserCubit, AddUserState>(
      buildWhen: (prevState, currState) {
        return prevState.firstName != currState.firstName;
      },
      builder: (context, state) {
        final errorMessage =
            state.firstName.displayError == UsernameValidationError.invalid
                ? 'اسم غير صالح'
                : 'يجب ان يكون الاسم مكون من حرفين على الاقل';
        return CustomTextInput(
          hintText: 'ادخل الاسم',
          value: state.firstName.value,
          onChanged:
              (val) => context.read<AddUserCubit>().firstNameChanged(val),
          errorText: state.firstName.displayError != null ? errorMessage : null,
        );
      },
    );
  }
}

class _LastNameInput extends StatelessWidget {
  _LastNameInput();

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.text = context.read<AddUserCubit>().state.lastName.value;
    return BlocBuilder<AddUserCubit, AddUserState>(
      buildWhen: (prevState, currState) {
        return prevState.lastName != currState.lastName;
      },
      builder: (context, state) {
        final errorMessage =
            state.lastName.displayError == UsernameValidationError.invalid
                ? 'اللقب غير صالح'
                : 'يجب ان يكون اللقب مكون من حرفين على الاقل';
        return CustomTextInput(
          hintText: 'كلمة اللقب',
          value: state.lastName.value,
          onChanged: (val) => context.read<AddUserCubit>().lastNameChanged(val),
          errorText: state.lastName.displayError != null ? errorMessage : null,
        );
      },
    );
  }
}

class _PhoneNumberInput extends StatelessWidget {
  _PhoneNumberInput({super.key});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.text = context.read<AddUserCubit>().state.number.value;
    return BlocBuilder<AddUserCubit, AddUserState>(
      buildWhen: (prevState, currState) {
        return prevState.number != currState.number;
      },
      builder: (context, state) {
        return TextField(
          onChanged: (value) {
            _controller.text = value;
            context.read<AddUserCubit>().numberChanged(_controller.text);
          },
          controller: _controller,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.blueGrey[700]!),
            ),
            filled: true,
            fillColor: Colors.grey[200],
            hintText: 'ادخل رقم الهاتف',
            errorText:
                state.number.displayError != null
                    ? ' يجب أن يحتوي على 10 أرقام. مثال:0796739638'
                    : null,
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: Icon(
              Icons.phone,
              color: Theme.of(context).colorScheme.primary,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        );
      },
    );
  }
}

class _CarNumberInput extends StatelessWidget {
  _CarNumberInput({super.key});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.text = context.read<AddUserCubit>().state.carNumber.value;
    return BlocBuilder<AddUserCubit, AddUserState>(
      buildWhen: (prevState, currState) {
        return prevState.carNumber != currState.carNumber;
      },
      builder: (context, state) {
        return TextField(
          onChanged: (value) {
            _controller.text = value;
            context.read<AddUserCubit>().carNumberChanged(_controller.text);
          },
          controller: _controller,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.blueGrey[700]!),
            ),
            filled: true,
            fillColor: Colors.grey[200],
            hintText: 'ادخل رقم الهاتف',
            errorText:
                state.carNumber.displayError != null
                    ? ' رقم لوحة السيارة غير صالح'
                    : null,
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: Icon(
              Icons.car_crash,
              color: Theme.of(context).colorScheme.primary,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  _PasswordInput({super.key});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.text = context.read<AddUserCubit>().state.password.value;
    return BlocBuilder<AddUserCubit, AddUserState>(
      buildWhen: (prevState, currState) {
        return prevState.password != currState.password ||
            prevState.hidePassword != currState.hidePassword;
      },
      builder: (context, state) {
        final errorMessage =
            state.firstName.displayError == UsernameValidationError.invalid
                ? 'يجب وضع كلمة المرور للمستخدم'
                : 'كلمة المرور قصيرة';
        return TextField(
          onChanged: (value) {
            _controller.text = value;
            context.read<AddUserCubit>().passwordChanged(_controller.text);
          },
          controller: _controller,
          obscureText: state.hidePassword,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.blueGrey[700]!),
            ),
            filled: true,
            fillColor: Colors.grey[200],
            hintText: 'ادخل كلمة المرور',
            hintStyle: const TextStyle(color: Colors.grey),
            errorText:
                state.password.displayError != null ? errorMessage : null,
            prefixIcon: Icon(
              Icons.lock,
              color: Theme.of(context).colorScheme.primary,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                context.read<AddUserCubit>().passwordVisibilityChanged();
              },
              icon: Icon(
                state.hidePassword ? Icons.visibility_off : Icons.visibility,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        );
      },
    );
  }
}

class _ConfirmPasswordInput extends StatelessWidget {
  _ConfirmPasswordInput();

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.text = context.read<AddUserCubit>().state.password.value;
    return BlocBuilder<AddUserCubit, AddUserState>(
      buildWhen: (prevState, currState) {
        return prevState.confirmedPassword != currState.confirmedPassword ||
            prevState.hidePassword != currState.hidePassword;
      },
      builder: (context, state) {
        return TextField(
          onChanged: (value) {
            _controller.text = value;
            context.read<AddUserCubit>().confirmedPasswordChanged(
              _controller.text,
            );
          },
          controller: _controller,
          obscureText: state.hidePassword,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.blueGrey[700]!),
            ),
            filled: true,
            fillColor: Colors.grey[200],
            hintText: 'تأكيد كلمة المرور',
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: Icon(
              Icons.lock,
              color: Theme.of(context).colorScheme.primary,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                context.read<AddUserCubit>().passwordVisibilityChanged();
              },
              icon: Icon(
                state.hidePassword ? Icons.visibility_off : Icons.visibility,
              ),
            ),
            errorText:
                state.confirmedPassword.displayError != null
                    ? 'كلمات المرور لا تتطابق'
                    : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        );
      },
    );
  }
}

class SignUpButton extends StatelessWidget {
  final User user;
  final UserRole role;

  const SignUpButton({super.key, required this.user, required this.role});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final state = context.watch<AddUserCubit>().state;
        final userListState = context.watch<UserListCubit>().state;

        return ElevatedButton(
          onPressed: () {
            logger.log(Logger.level, user.firstName);
            if (state.isValid) {
              if (user == User.empty) {
                context.read<UserListCubit>().addUser(
                  User(
                    firstName: state.firstName.value,
                    number: state.number.value,
                    carNumber: state.carNumber.value,
                    status: role,
                    lastName: state.lastName.value,
                    password: state.password.value,
                  ),
                );
                //context.pushReplacementNamed(AppRoutes.Home);
              } else {
                context.read<UserListCubit>().updateUser(
                  user,
                  User(
                    id: user.id,
                    firstName: state.firstName.value,
                    number: state.number.value,
                    carNumber: state.carNumber.value,
                    lastName: state.lastName.value,
                    password: state.password.value,
                  ),
                );
              }
            } else {
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
            fixedSize: MaterialStateProperty.all<Size>(const Size(300.0, 48.0)),
            backgroundColor: MaterialStateProperty.all<Color>(
              Theme.of(context).colorScheme.primary,
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            elevation: MaterialStateProperty.all(5),
            shadowColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
          ),
          child:
              userListState.status == UserListStatus.loading
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
        );
      },
    );
  }
}
