import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:maps_app/main.dart';
import 'package:maps_app/ui/widgets/custom_text_input.dart';
import 'package:maps_app/utils/constants.dart';
import 'package:maps_app/utils/formz/password.dart';
import '../../utils/get_it.dart';
import '../../utils/formz/username.dart';
import '../bloc/authentication/authentication_bloc.dart';
import '../bloc/authentication/authentication_event.dart';
import '../bloc/login/login_cubit.dart';
import '../bloc/login/login_state.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SafeArea(
        child: Scaffold(
          body: BlocProvider<LoginCubit>(
            create: (context) => getIt(),
            child: const _LoginForm(),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (prevState, currState) {
        return prevState.loginStatus != currState.loginStatus;
      },
      listener: (context, state) {
        if (state.loginStatus == LoginStatus.failed) {
          Constants.showSnackBar(
            context,
            Icons.library_add_check,
            state.errorMessage ?? 'failed to login',
            Colors.redAccent,
            Duration(seconds: 2),
          );
        }
        if (state.loginStatus == LoginStatus.success) {
          logger.log(Logger.level, 'login successful');
          context.read<AuthenticationBloc>().add(AdminLoginRequested(state.role!));
          context.pop();
        }
      },
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipPath(
              clipper: OvalBottomBorderClipper(),
              child: Image(
                image: Image.asset('assets/login_img.png').image,
                height: 180,
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تسجيل الدخول',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildLabel('الاسم', theme),
                  _FirstNameInput(),
                  const SizedBox(height: 20),
                  buildLabel('اللقب', theme),
                  _LastNameInput(),
                  const SizedBox(height: 20),
                  buildLabel('كلمة المرور', theme),
                  _PasswordInput(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const _LoginButton(),
          ],
        ),
      ),
    );
  }

  Widget buildLabel(String labelText, ThemeData theme) {
    return Text(labelText, style: theme.textTheme.titleMedium);
  }
}

class _FirstNameInput extends StatelessWidget {
  const _FirstNameInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
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
          onChanged: (val) => context.read<LoginCubit>().firstNameChanged(val),
          errorText: state.firstName.displayError != null ? errorMessage : null,
        );
      },
    );
  }
}

class _LastNameInput extends StatelessWidget {
  _LastNameInput();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (prevState, currState) {
        return prevState.lastName != currState.lastName;
      },
      builder: (context, state) {
        final errorMessage =
            state.lastName.displayError == UsernameValidationError.invalid
                ? 'اللقب غير صالح'
                : 'يجب ان يكون اللقب مكون من حرفين على الاقل';
        return CustomTextInput(
          hintText: 'ادخل اللقب',
          value: state.lastName.value,
          onChanged: (val) => context.read<LoginCubit>().lastNameChanged(val),
          errorText: state.lastName.displayError != null ? errorMessage : null,
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  const _PasswordInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (prevState, currState) {
        return prevState.password != currState.password ||
            prevState.hidePassword != currState.hidePassword;
      },
      builder: (context, state) {
        final errorMessage =
            state.password.displayError == PasswordValidationError.invalid
                ? 'يجب وضع كلمة المرور للمستخدم'
                : 'كلمة المرور قصيرة';
        return CustomTextInput(
          hintText: 'كلمة المرور',
          value: state.password.value,
          onChanged: (val) => context.read<LoginCubit>().passwordChanged(val),
          obscureText: state.hidePassword,
          passwordMode: true,
          onHidePassword: (){
            context.read<LoginCubit>().passwordVisibilityChanged();
          },
          icon: Icons.lock_outline,
          errorText: state.password.displayError != null ? errorMessage : null,
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            if (state.isValid) {
              context.read<LoginCubit>().signIn();
            } else {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('فشل التحقق من البيانات')),
                );
            }
          },
          style: ButtonStyle(
            fixedSize: WidgetStateProperty.all<Size>(const Size(300.0, 48.0)),
            backgroundColor: WidgetStateProperty.all<Color>(
              theme.colorScheme.primary,
            ),
          ),
          child:
              state.loginStatus == LoginStatus.loading
                  ? CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary,
                  )
                  : Text(
                    'تسجيل الدخول',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
        );
      },
    );
  }
}
