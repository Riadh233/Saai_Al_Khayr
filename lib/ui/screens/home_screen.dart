import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as  material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:logger/logger.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:maps_app/data/models/user.dart';
import 'package:maps_app/main.dart';
import 'package:maps_app/ui/screens/admin/mission/admin_missions_screen.dart';
import 'package:maps_app/ui/screens/admin/money_collection_screen.dart';
import 'package:maps_app/ui/screens/admin/mosques/mosques_list.dart';
import 'package:maps_app/ui/screens/driver/driver_missions_screen.dart';
import 'package:maps_app/ui/screens/imam/imam_missions_screen.dart';
import 'package:maps_app/ui/screens/imam/imam_screen.dart';
import 'package:maps_app/ui/screens/map_screen.dart';
import '../bloc/authentication/authentication_bloc.dart';
import '../bloc/authentication/authentication_state.dart';
import '../bloc/bottom_nav_cubit/bottom_nav_cubit.dart';
import '../bloc/bottom_nav_cubit/bottom_nav_state.dart';
import 'admin/user/user_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {

    return Directionality(
      textDirection: material.TextDirection.ltr,
      child: SafeArea(
        child: BlocBuilder<AuthenticationBloc,AuthenticationState>(
          builder: (context, state) {
            logger.log(Logger.level, 'user role..... ${state.userRole}');
            final userRole  = state.userRole;
            if(userRole == null || state.status == AuthenticationStatus.unknown){
              logger.log(Logger.level, 'loading the user role ...');
              return Scaffold(
                body: Center(
                  child: SpinKitThreeBounce(
                    color: Theme.of(context).colorScheme.secondary,
                    size: 40.0,
                  ),
                ),
              );
            }else{
              logger.log(Logger.level, 'user role..... ${state.userRole}');
              return _getScreenForRole(userRole);
            }
          }
        ),
      ),
    );
  }
  Widget _getScreenForRole(UserRole role){
    switch(role){
      case UserRole.admin :
        return _AdminHomeScreen();
      case UserRole.driver :
        return _DriverHomeScreen();
      case UserRole.imam :
        return _ImamHomeScreen();
    }
  }
}

class _ImamHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocSelector<BottomNavCubit,BottomNavState, int>(
        selector: (state) => state.selectedTab,
        builder: (context, int selectedTab ) {
          return Scaffold(
              body: _getSelectedScreen(selectedTab),
              bottomNavigationBar: BottomNavigationBar(
                selectedItemColor: theme.colorScheme.primary,
                unselectedItemColor: theme.colorScheme.onSurfaceVariant,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    label: 'الملف الشخصي',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.car_crash_outlined),
                    label: 'المهام',
                  ),
                ],
                currentIndex: selectedTab,
                onTap: (index){
                  context.read<BottomNavCubit>().selectedTabChanged(index);
                },
              )
          );
        }
    );
  }
  Widget _getSelectedScreen(int index){
    switch(index){
      case 0 :
        return ImamScreen();

      default : return ImamMissionsScreen();
    }
  }
}

class _DriverHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocSelector<BottomNavCubit,BottomNavState, int>(
        selector: (state) => state.selectedTab,
        builder: (context, int selectedTab ) {
        return Scaffold(
          body: _getSelectedScreen(selectedTab),
            bottomNavigationBar: BottomNavigationBar(
              selectedItemColor: theme.colorScheme.primary,
              unselectedItemColor: theme.colorScheme.onSurfaceVariant,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.location_on),
                    label: 'الخريطة'
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.mosque_outlined),
                    label: 'المهام'
                ),
              ],
              currentIndex: selectedTab,
              onTap: (index){
                context.read<BottomNavCubit>().selectedTabChanged(index);
              },
            )
        );
      }
    );
  }

  Widget _getSelectedScreen(int index){
    switch(index){
      case 0 :
        return MapScreenPage();
      case 1 :
        return DriverMissionsScreen();

      default : return MapScreenPage();
    }
  }
}

class _AdminHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocSelector<BottomNavCubit,BottomNavState,int>(
        selector: (state) => state.selectedTab,
        builder: (context,int selectedTab) {
          return Scaffold(
              body: _getSelectedScreen(selectedTab),
              bottomNavigationBar: BottomNavigationBar(
                selectedItemColor: theme.colorScheme.primary,
                unselectedItemColor: theme.colorScheme.onSurfaceVariant,
                items:  [
                  BottomNavigationBarItem(
                    icon: Icon(LucideIcons.map),
                    label: 'الخريطة',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.mosque_outlined),
                    label: 'المساجد',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_add_alt_outlined),
                    label: 'المستخدمون',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.car_crash_outlined),
                    label: 'المهام',
                  ),
                  BottomNavigationBarItem(
                    icon : Icon(Icons.receipt_long_outlined),
                    label: 'سجل التبرعات',
                  ),

                ],
                currentIndex: selectedTab,
                onTap: (index){
                  context.read<BottomNavCubit>().selectedTabChanged(index);
                },
              )
          );
        }
    );
  }
  Widget _getSelectedScreen(int index){
    switch(index){
      case 0 :
        return MapScreenPage();
      case 1 :
        return MosqueListScreen();
      case 2 :
        return UserListScreen();
      case 3 :
        return AdminMissionsScreen();

      default : return MoneyCollectionScreen();
    }
  }
}