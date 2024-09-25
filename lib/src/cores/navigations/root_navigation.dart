import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haiyowangi/src/index.dart';
import 'package:haiyowangi/src/views/products/variants/index.dart';
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
      routes: [
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
            pageBuilder: renderFadeTransition(const ProductsView())
          ),
          GoRoute(
            path: appRoutes.ingredient.path,
            name: appRoutes.ingredient.name,
            pageBuilder: renderFadeTransition(const IngredientsView())
          ),
          GoRoute(
            path: appRoutes.packet.path,
            name: appRoutes.packet.name,
            pageBuilder: renderFadeTransition(const PacketsView())
          ),
          GoRoute(
            path: appRoutes.discount.path,
            name: appRoutes.discount.name,
            pageBuilder: renderFadeTransition(const DiscountsView())
          ),
          GoRoute(
            path: appRoutes.sales.path,
            name: appRoutes.sales.name,
            pageBuilder: renderFadeTransition(const SalesView())
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
            pageBuilder: renderFadeTransition(const IncomingsStockView())
          ),
          GoRoute(
            path: appRoutes.outgoingStock.path,
            name: appRoutes.outgoingStock.name,
            pageBuilder: renderFadeTransition(const OutgoingsStockView())
          ),
          GoRoute(
            path: appRoutes.staff.path,
            name: appRoutes.staff.name,
            pageBuilder: renderFadeTransition(const StaffsView())
          ),
        ],
    ),

    GoRoute(
      path: appRoutes.formProduct.path, 
      name: appRoutes.formProduct.name, 
      pageBuilder: renderSlideTransition(const FormProductView()),
    ),
    GoRoute(
      path: appRoutes.detailProduct.path, 
      name: appRoutes.detailProduct.name, 
      pageBuilder: (context, state) {
        return renderSlideTransition(
          DetailProductView(data: state.extra.toString()),
        )(context, state);
      },
    ),
    GoRoute(
      path: appRoutes.editProduct.path, 
      name: appRoutes.editProduct.name, 
      pageBuilder: (context, state) {
        return renderSlideTransition(
          EditProductView(data: state.extra.toString()),
        )(context, state);
      },
    ),
    GoRoute(
      path: appRoutes.copyProduct.path, 
      name: appRoutes.copyProduct.name, 
      pageBuilder: renderSlideTransition(const CopyProductView()),
    ),
   
    GoRoute(
      path: appRoutes.formOfficeInventory.path, 
      name: appRoutes.formOfficeInventory.name, 
      pageBuilder: renderSlideTransition(const FormOfficeInventoryView()),
    ),
    GoRoute(
      path: appRoutes.detailOfficeInventory.path, 
      name: appRoutes.detailOfficeInventory.name, 
      pageBuilder: (context, state) {
        return renderSlideTransition(
          DetailOfficeInventoryView(data: state.extra.toString()),
        )(context, state);
      },
    ),

    GoRoute(
      path: appRoutes.formIncome.path, 
      name: appRoutes.formIncome.name, 
      pageBuilder: renderSlideTransition(const FormIncomeView()),
    ),
    GoRoute(
      path: appRoutes.detailIncome.path, 
      name: appRoutes.detailIncome.name, 
      pageBuilder: (context, state) {
        return renderSlideTransition(
          DetailIncomeView(data: state.extra.toString()),
        )(context, state);
      }
    ),
    
    GoRoute(
      path: appRoutes.formExpense.path, 
      name: appRoutes.formExpense.name, 
      pageBuilder: renderSlideTransition(const FormExpenseView()),
    ),
    GoRoute(
      path: appRoutes.detailExpense.path, 
      name: appRoutes.detailExpense.name, 
      pageBuilder: (context, state) {
        return renderSlideTransition(
          DetailExpenseView(data: state.extra.toString()),
        )(context, state);
      }
    ),
    
    GoRoute(
      path: appRoutes.formStaff.path, 
      name: appRoutes.formStaff.name, 
      pageBuilder: renderSlideTransition(const FormStaffView()),
    ),
    GoRoute(
      path: appRoutes.detailStaff.path, 
      name: appRoutes.detailStaff.name, 
      pageBuilder: (context, state) {
        return renderSlideTransition(
          DetailStaffView(data: state.extra.toString()),
        )(context, state);
      }
    ),
    
    GoRoute(
      path: appRoutes.formIngredient.path, 
      name: appRoutes.formIngredient.name, 
      pageBuilder: renderSlideTransition(const FormIngredientView()),
    ),
    GoRoute(
      path: appRoutes.detailIngredient.path, 
      name: appRoutes.detailIngredient.name, 
      pageBuilder: (context, state) {
        return renderSlideTransition(
          DetailIngredientView(data: state.extra.toString()),
        )(context, state);
      }
    ),
    
    GoRoute(
      path: appRoutes.formPacket.path, 
      name: appRoutes.formPacket.name, 
      pageBuilder: renderSlideTransition(const FormPacketView()),
    ),
    GoRoute(
      path: appRoutes.detailPacket.path, 
      name: appRoutes.detailPacket.name, 
      pageBuilder: (context, state) {
        return renderSlideTransition(
          DetailPacketView(data: state.extra.toString()),
        )(context, state);
      }
    ),
    
    GoRoute(
      path: appRoutes.formVariant.path, 
      name: appRoutes.formVariant.name, 
      pageBuilder: (context, state) {
        return renderSlideTransition(
          FormVariantView(data: state.extra.toString()),
        )(context, state);
      },
    ),
    GoRoute(
      path: appRoutes.editVariant.path, 
      name: appRoutes.editVariant.name, 
      pageBuilder: (context, state) {
        return renderSlideTransition(
          EditVariantView(data: state.extra.toString()),
        )(context, state);
      },
    ),
    GoRoute(
      path: appRoutes.detailVariant.path, 
      name: appRoutes.detailVariant.name, 
      pageBuilder: (context, state) {
        return renderSlideTransition(
          DetailVariantView(data: state.extra.toString()),
        )(context, state);
      },
    ),
    GoRoute(
      path: appRoutes.manageVariant.path, 
      name: appRoutes.manageVariant.name, 
      pageBuilder: (context, state) {
        return renderSlideTransition(
          ManageVariantView(data: state.extra.toString()),
        )(context, state);
      },
    ),

    GoRoute(
      path: appRoutes.formIncomingStock.path, 
      name: appRoutes.formIncomingStock.name, 
      pageBuilder: renderSlideTransition(const FormIncomingStockView()),
    ),
    GoRoute(
      path: appRoutes.detailIncomingStock.path, 
      name: appRoutes.detailIncomingStock.name, 
      pageBuilder: (context, state) {
        return renderSlideTransition(
          DetailIncomingStockView(data: state.extra.toString()),
        )(context, state);
      },
    ),
    
    GoRoute(
      path: appRoutes.formOutgoingStock.path, 
      name: appRoutes.formOutgoingStock.name, 
      pageBuilder: renderSlideTransition(const FormOutgoingStockView()),
    ),
    GoRoute(
      path: appRoutes.detailOutgoingStock.path, 
      name: appRoutes.detailOutgoingStock.name, 
      pageBuilder: (context, state) {
        return renderSlideTransition(
          DetailOutgoingStockView(data: state.extra.toString()),
        )(context, state);
      },
    ),
    
    GoRoute(
      path: appRoutes.formDiscount.path, 
      name: appRoutes.formDiscount.name, 
      pageBuilder: renderSlideTransition(const FormDiscountView()),
    ),
    GoRoute(
      path: appRoutes.detailDiscount.path, 
      name: appRoutes.detailDiscount.name, 
      pageBuilder: (context, state) {
        return renderSlideTransition(
          DetailDiscountView(data: state.extra.toString()),
        )(context, state);
      },
    ),

    GoRoute(
      path: appRoutes.detailSale.path, 
      name: appRoutes.detailSale.name, 
      pageBuilder: (context, state) {
        return renderSlideTransition(
          DetailSaleView(data: state.extra.toString()),
        )(context, state);
      },
    ),
    GoRoute(
      path: appRoutes.detailPayment.path, 
      name: appRoutes.detailPayment.name, 
      pageBuilder: (context, state) {
        return renderSlideTransition(
          DetailSaleView(data: state.extra.toString()),
        )(context, state);
      },
    ),

  ]
);
