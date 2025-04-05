import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/screens/map_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static GoRouter router() {
    final router = GoRouter(
      initialLocation: '/home',
      routes: <RouteBase>[
        GoRoute(
          path: 'map',
          name: AppRoutes.Map,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return MaterialPage(key: state.pageKey, child: MapScreen());
          },
        ),
      ],
    );

    return router;
  }
}
