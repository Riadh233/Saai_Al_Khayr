import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_app/data/models/user.dart';
import 'package:maps_app/ui/screens/admin/map_preview.dart';
import 'package:maps_app/ui/screens/admin/mission/admin_missions_screen.dart';
import 'package:maps_app/ui/screens/admin/mosques/add_mosque_screen.dart';
import 'package:maps_app/ui/screens/admin/mosques/mosques_list.dart';
import 'package:maps_app/ui/screens/admin/user/user_details.dart';
import 'package:maps_app/ui/screens/admin/user/user_list.dart';
import 'package:maps_app/ui/screens/home_screen.dart';
import 'package:maps_app/ui/screens/imam/imam_screen.dart';
import 'package:maps_app/ui/screens/login.dart';

import '../ui/screens/admin/user/add_user.dart';
import '../ui/screens/map_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static GoRouter router(bool isAuth) {
    final router = GoRouter(
      initialLocation: '/home',
      routes: <RouteBase>[
        GoRoute(
          path: '/home',
          name: AppRoutes.Home,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return MaterialPage(key: state.pageKey, child: HomeScreen());
          },
        ),
        GoRoute(
          path: '/map',
          name: AppRoutes.Map,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return MaterialPage(key: state.pageKey, child: MapScreenPage());
          },
        ),
        GoRoute(
          path: '/add_user',
          name: AppRoutes.AddUser,
          pageBuilder: (BuildContext context, GoRouterState state) {
            final extra = state.extra as Map<String,dynamic>;
            final role = extra['role'] as UserRole;
            final user = extra['user'] as User?;
            return MaterialPage(key: state.pageKey, child: AddUserScreen(role : role,user: user ?? User.empty,));
          },
        ),
        GoRoute(
          path: '/login',
          name: AppRoutes.Login,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return MaterialPage(key: state.pageKey, child: LoginScreen());
          },
        ),
        GoRoute(
          path: '/users_list',
          name: AppRoutes.UserList,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return MaterialPage(key: state.pageKey, child: UserListScreen());
          },
        ),
        GoRoute(
          path: '/users_details',
          name: AppRoutes.UserDetails,
          pageBuilder: (BuildContext context, GoRouterState state) {
            final user = state.extra as User;
            return MaterialPage(key: state.pageKey, child: UserDetailsScreen(user: user));
          },
        ),
        GoRoute(
          path: '/add_mosque',
          name: AppRoutes.AddMosque,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return MaterialPage(key: state.pageKey, child: AddMosqueScreen(mosqueId: state.extra as int?,));
          },
        ),
        GoRoute(
          path: '/mosque_list',
          name: AppRoutes.MosqueList,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return MaterialPage(key: state.pageKey, child: MosqueListScreen());
          },
        ),
        GoRoute(
          path: '/map_preview',
          name: AppRoutes.MapPreview,
          pageBuilder: (BuildContext context, GoRouterState state) {
            final location = state.extra as LatLng;
            return MaterialPage(key: state.pageKey, child: MapPreviewScreen(location: location));
          },
        ),
        GoRoute(
          path: '/missions_list',
          name: AppRoutes.MissionsList,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return MaterialPage(key: state.pageKey, child: AdminMissionsScreen());
          },
        ),
        GoRoute(
          path: '/imam_screen',
          name: AppRoutes.ImamScreen,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return MaterialPage(key: state.pageKey, child: ImamScreen());
          },
        ),
      ],
        redirect: (context,state){
          if (!isAuth) {
            if (state.matchedLocation == '/home') {
              return '/login';
            } else {
              return null;
            }
          } else {
            if (state.matchedLocation == '/login') {
              return '/home';
            } else {
              return null;
            }
          }
        }
    );

    return router;
  }
}
