
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:logger/logger.dart';
import 'package:maps_app/routing/app_router.dart';
import 'package:maps_app/ui/bloc/authentication/authentication_bloc.dart';
import 'package:maps_app/ui/bloc/authentication/authentication_event.dart';
import 'package:maps_app/ui/bloc/authentication/authentication_state.dart';
import 'package:maps_app/ui/bloc/bottom_nav_cubit/bottom_nav_cubit.dart';
import 'package:maps_app/ui/bloc/driver/missions/driver_missions_cubit.dart';
import 'package:maps_app/ui/bloc/imam/imam_cubit.dart';
import 'package:maps_app/ui/bloc/imam/imam_missions_cubit.dart';
import 'package:maps_app/ui/bloc/internet_connection/internet_connection_bloc.dart';
import 'package:maps_app/ui/bloc/location_cubit/location_cubit.dart';
import 'package:maps_app/ui/bloc/login/login_cubit.dart';
import 'package:maps_app/ui/bloc/missions/mission_list_cubit.dart';
import 'package:maps_app/ui/bloc/mosque/add_mosque_cubit.dart';
import 'package:maps_app/ui/bloc/mosque/mosque_list_cubit.dart';
import 'package:maps_app/ui/bloc/user_list/user_list_cubit.dart';
import 'package:maps_app/ui/theme/fonts.dart';
import 'package:maps_app/ui/theme/theme.dart';
import 'data/models/user.dart';
import 'data/notification_service.dart';
import 'utils/get_it.dart';

final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init(); // local notifications
  await dotenv.load(fileName: ".env");
  await initializeDependencies();


  runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(create: (context) =>
          getIt()
            ..add(AppStarted())),
          BlocProvider<LoginCubit>(create: (context) => getIt<LoginCubit>()),
        ],
        child: MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context
        .watch<AuthenticationBloc>()
        .state;
    final isAuth = authState.status == AuthenticationStatus.authenticated;
    final userRole = authState.userRole;

    if (authState.status == AuthenticationStatus.unknown) {
      TextTheme textTheme = createTextTheme(context);
      MaterialTheme theme = MaterialTheme(textTheme);
      final brightness = View
          .of(context)
          .platformDispatcher
          .platformBrightness;
      return  MaterialApp(
        theme: brightness == Brightness.light ? theme.light() : theme.dark(),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: SpinKitThreeBounce(
            color: Theme.of(context).colorScheme.secondary,
            size: 40.0,
          )),
        ),
      );
    }

    return AppViewScreen(isAuth: isAuth, role: UserRole.admin);
  }
}


class AppViewScreen extends StatefulWidget {
  final bool isAuth;
  final UserRole? role;

  const AppViewScreen({super.key, required this.isAuth, required this.role});

  @override
  State<AppViewScreen> createState() => _AppViewScreenState();
}

class _AppViewScreenState extends State<AppViewScreen> {

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: getProvidersForRole(widget.role),
      child: AppView(isAuth:
          true
      //widget.isAuth
      ),
    );
  }

  List<BlocProvider> getProvidersForRole(UserRole? role) {
    List<BlocProvider> providers = [
      BlocProvider<UserLocationCubit>(
        create: (context) {
          final cubit = getIt<UserLocationCubit>();
          if (role == UserRole.driver) {
            cubit.startLocationUpdates();
          }
          return cubit;
        },
      ),
      BlocProvider<UserListCubit>(create: (context) => getIt()),
      BlocProvider<BottomNavCubit>(create: (context) => getIt()),
      BlocProvider<InternetConnectionBloc>(create: (context) => getIt()),
      BlocProvider<AddMosqueCubit>(create: (context) => getIt()),
      BlocProvider<MosqueListCubit>(create: (context) => getIt()),
      BlocProvider<MissionsListCubit>(create: (context) => getIt()),
      BlocProvider<DriverMissionsCubit>(create: (context) => getIt()),
      BlocProvider<ImamCubit>(create: (context) => getIt()),
      BlocProvider<ImamMissionsCubit>(create: (context) => getIt()),
    ];
    return providers;
  }
}

class AppView extends StatelessWidget {
  final bool isAuth;

  const AppView({super.key, required this.isAuth});

  @override
  Widget build(BuildContext context) {
    logger.log(Logger.level, isAuth);
    final router = AppRouter.router(
        isAuth
      // authState.status == AuthenticationStatus.authenticated
    );
    final FlutterLocalization localization = FlutterLocalization.instance;
    TextTheme textTheme = createTextTheme(context);
    MaterialTheme theme = MaterialTheme(textTheme);
    final brightness = View
        .of(context)
        .platformDispatcher
        .platformBrightness;
    return MaterialApp.router(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      localizationsDelegates: localization.localizationsDelegates,
      supportedLocales: <Locale>[
        Locale('ar', 'DZ'), // English
      ],
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
