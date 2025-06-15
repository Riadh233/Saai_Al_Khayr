import 'package:get_it/get_it.dart';
import 'package:maps_app/data/api/database_service.dart';
import 'package:maps_app/data/api/driver_api_service.dart';
import 'package:maps_app/data/api/imam_api_service.dart';
import 'package:maps_app/data/local/local_storage_repository.dart';
import 'package:maps_app/ui/bloc/add_user/add_user_cubit.dart';
import 'package:maps_app/ui/bloc/authentication/authentication_bloc.dart';
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


final getIt = GetIt.instance;

Future<void> initializeDependencies() async {

  getIt.registerFactory<LoginCubit>(() => LoginCubit(getIt()));
  getIt.registerSingleton<LocalStorageRepository>(LocalStorageRepository());
  getIt.registerLazySingleton<DatabaseService>(
        () => DatabaseService(localStorage: getIt()),
  );
  getIt.registerLazySingleton<DriverApiService>(
        () => DriverApiService(localStorage: getIt()),
  );
  getIt.registerLazySingleton<ImamApiService>(
        () => ImamApiService(localStorage: getIt()),
  );

  // Essential services used across all roles
  getIt.registerLazySingleton<InternetConnectionBloc>(
        () => InternetConnectionBloc(),
  );
  getIt.registerLazySingleton<BottomNavCubit>(
        () => BottomNavCubit(),
  );

  getIt.registerLazySingleton<AuthenticationBloc>(
        () => AuthenticationBloc(
      localStorageRepository: getIt<LocalStorageRepository>(),
      databaseService: getIt<DatabaseService>(),
    ),
  );


  getIt.registerFactory<AddMosqueCubit>(() => AddMosqueCubit(getIt()));
  getIt.registerFactory<MosqueListCubit>(() => MosqueListCubit(getIt()));
  getIt.registerFactory<UserListCubit>(() => UserListCubit(getIt()));
  getIt.registerFactory<AddUserCubit>(() => AddUserCubit());
  getIt.registerLazySingleton<UserLocationCubit>(() => UserLocationCubit());
  getIt.registerFactory<MissionsListCubit>(() => MissionsListCubit(getIt()));
  getIt.registerFactory<DriverMissionsCubit>(() => DriverMissionsCubit(getIt()));
  getIt.registerFactory<ImamCubit>(() => ImamCubit(getIt()));
  getIt.registerFactory<ImamMissionsCubit>(() => ImamMissionsCubit(getIt()));

}

// void setupRoleBasedDependencies(UserRole role) {
//   switch (role) {
//     case UserRole.admin:
//       // getIt.registerLazySingleton<AddMosqueCubit>(() => AddMosqueCubit(getIt()));
//       // getIt.registerLazySingleton<MosqueListCubit>(() => MosqueListCubit(getIt()));
//       // getIt.registerLazySingleton<UserListCubit>(() => UserListCubit(getIt()));
//       // getIt.registerLazySingleton<UserLocationCubit>(() => UserLocationCubit());
//       // getIt.registerLazySingleton<OrsCubit>(() => OrsCubit(getIt()));
//       // getIt.registerLazySingleton<MissionsListCubit>(() => MissionsListCubit(getIt()));
//       break;
//     case UserRole.driver:
//       // getIt.registerLazySingleton<UserLocationCubit>(() => UserLocationCubit());
//       // getIt.registerLazySingleton<OrsCubit>(() => OrsCubit(getIt()));
//       // getIt.registerLazySingleton<MissionsListCubit>(() => MissionsListCubit(getIt()));
//       break;
//     case UserRole.imam:
//       // getIt.registerLazySingleton<MosqueListCubit>(() => MosqueListCubit(getIt()));
//       // getIt.registerLazySingleton<MissionsListCubit>(() => MissionsListCubit(getIt()));
//       break;
//   }
// }
