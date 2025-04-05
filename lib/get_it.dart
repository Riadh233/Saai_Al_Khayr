import 'package:get_it/get_it.dart';
import 'package:maps_app/data/ors_repository.dart';
import 'package:maps_app/domain/location_cubit/location_cubit.dart';
import 'package:maps_app/domain/ors_cubit/ors_cubit.dart';


final getIt = GetIt.instance;

Future<void> initializeDependencies() async{
  getIt.registerSingleton<OpenRouteServiceRepository>(OpenRouteServiceRepository());
  getIt.registerFactory<UserLocationCubit>(() => UserLocationCubit());
  getIt.registerFactory<OrsCubit>(() => OrsCubit(getIt()));
}