import 'base_interface.dart';

class AppRoutes {
  
  final Route login;
  final Route register;
  final Route registerStore;
  final Route stores;

  final Route dashboard;

  const AppRoutes({
    this.login = const Route(name: "login", path: "/"),
    this.register = const Route(name: "register", path: "/register"),
    this.registerStore = const Route(name: "register/store", path: "/register/store"),
    this.stores = const Route(name: "stores", path: "/stores"),
    this.dashboard = const Route(name: "dashboard", path: "/dashboard"),
  });
}

const appRoutes = AppRoutes();
