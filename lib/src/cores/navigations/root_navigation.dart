import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haiyowangi/src/index.dart';
import 'animations/index.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellDrawerNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'drawerGrouppedShell');
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: "/",
  debugLogDiagnostics: true,
  routes: [
    GoRoute(path: appRoutes.login.path, name: appRoutes.login.name, builder: (c, s) => const LoginView()),
    GoRoute(path: appRoutes.register.path, name: appRoutes.register.name, builder: (c, s) => const RegisterView()),
    GoRoute(path: appRoutes.registerStore.path, name: appRoutes.registerStore.name, builder: (c, s) => const RegisterStoreView()),
    GoRoute(path: appRoutes.stores.path, name: appRoutes.stores.name, builder: (c, s) => const StoresView()),
    ShellRoute(
      navigatorKey: shellDrawerNavigatorKey,
      builder: (ctx, s, c) => DrawerGroupedShell(child: c),
      routes: <RouteBase>[
          GoRoute(
            path: appRoutes.dashboard.path,
            name: appRoutes.dashboard.name,
            pageBuilder: renderFadeTransition(const DashboardView())
          ),
        ],
    ),
  ]
);
