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
      builder: (ctx, s, c) => DrawerGroupedShell(state: s, child: c),
      routes: <RouteBase>[

          GoRoute(
            path: appRoutes.account.path,
            name: appRoutes.account.name,
            pageBuilder: renderFadeTransition(const AccountView())
          ),
          GoRoute(
            path: appRoutes.dashboard.path,
            name: appRoutes.dashboard.name,
            pageBuilder: renderFadeTransition(const DashboardView())
          ),
          GoRoute(
            path: appRoutes.notification.path,
            name: appRoutes.notification.name,
            pageBuilder: renderFadeTransition(const NotificationsView())
          ),
          GoRoute(
            path: appRoutes.yourstores.path,
            name: appRoutes.yourstores.name,
            pageBuilder: renderFadeTransition(const MyStoresView())
          ),
          GoRoute(
            path: appRoutes.product.path,
            name: appRoutes.product.name,
            pageBuilder: renderFadeTransition(const PlaceholderView())
          ),
          GoRoute(
            path: appRoutes.packet.path,
            name: appRoutes.packet.name,
            pageBuilder: renderFadeTransition(const PlaceholderView())
          ),
          GoRoute(
            path: appRoutes.discount.path,
            name: appRoutes.discount.name,
            pageBuilder: renderFadeTransition(const PlaceholderView())
          ),
          GoRoute(
            path: appRoutes.sales.path,
            name: appRoutes.sales.name,
            pageBuilder: renderFadeTransition(const PlaceholderView())
          ),
          GoRoute(
            path: appRoutes.payment.path,
            name: appRoutes.payment.name,
            pageBuilder: renderFadeTransition(const PlaceholderView())
          ),
          GoRoute(
            path: appRoutes.store.path,
            name: appRoutes.store.name,
            pageBuilder: renderFadeTransition(const StoreView())
          ),
          GoRoute(
            path: appRoutes.officeInventory.path,
            name: appRoutes.officeInventory.name,
            pageBuilder: renderFadeTransition(const OfficeInventoriesView())
          ),
          GoRoute(
            path: appRoutes.income.path,
            name: appRoutes.income.name,
            pageBuilder: renderFadeTransition(const IncomesView())
          ),
          GoRoute(
            path: appRoutes.expense.path,
            name: appRoutes.expense.name,
            pageBuilder: renderFadeTransition(const ExpensesView())
          ),
          GoRoute(
            path: appRoutes.incomingStock.path,
            name: appRoutes.incomingStock.name,
            pageBuilder: renderFadeTransition(const PlaceholderView())
          ),
          GoRoute(
            path: appRoutes.outgoingStock.path,
            name: appRoutes.outgoingStock.name,
            pageBuilder: renderFadeTransition(const PlaceholderView())
          ),
          GoRoute(
            path: appRoutes.staff.path,
            name: appRoutes.staff.name,
            pageBuilder: renderFadeTransition(const StaffsView())
          ),
        ],
    ),

    GoRoute(path: appRoutes.formOfficeInventory.path, name: appRoutes.formOfficeInventory.name, builder: (c, s) => const FormOfficeInventoryView()),
    GoRoute(path: appRoutes.detailOfficeInventory.path, name: appRoutes.detailOfficeInventory.name, builder: (c, s) => DetailOfficeInventoryView(data: s.extra.toString())),

    GoRoute(path: appRoutes.formIncome.path, name: appRoutes.formIncome.name, builder: (c, s) => const FormIncomeView()),
    GoRoute(path: appRoutes.detailIncome.path, name: appRoutes.detailIncome.name, builder: (c, s) => DetailIncomeView(data: s.extra.toString())),
    
    GoRoute(path: appRoutes.formExpense.path, name: appRoutes.formExpense.name, builder: (c, s) => const FormExpenseView()),
    GoRoute(path: appRoutes.detailExpense.path, name: appRoutes.detailExpense.name, builder: (c, s) => DetailExpenseView(data: s.extra.toString())),
    
    GoRoute(path: appRoutes.formStaff.path, name: appRoutes.formStaff.name, builder: (c, s) => const FormStaffView()),
    GoRoute(path: appRoutes.detailStaff.path, name: appRoutes.detailStaff.name, builder: (c, s) => DetailStaffView(data: s.extra.toString())),

  ]
);
