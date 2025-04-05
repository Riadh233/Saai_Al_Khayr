import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:maps_app/domain/location_cubit/location_cubit.dart';
import 'package:maps_app/domain/ors_cubit/ors_cubit.dart';
import 'package:maps_app/routing/app_router.dart';

import 'get_it.dart';

void main() async{
  await dotenv.load();  // Load environment variables
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider<UserLocationCubit>(
        create: (context) => getIt()..getCurrentLocation(),
      ),
      BlocProvider<OrsCubit>(
        create: (context) => getIt(),
      ),
    ], child: AppView());
  }
}

class AppView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final router = AppRouter.router();
    final FlutterLocalization localization = FlutterLocalization.instance;

    return  MaterialApp.router(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
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
