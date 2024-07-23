import 'base_interface.dart';

class AppRoutes {
  
  final Route login;
  final Route register;
  final Route registerStore;
  final Route stores;

  final Route dashboard;
  final Route notification;

  final Route product;
  final Route variant;
  final Route packet;
  final Route ingredient;
  final Route discount;
  final Route sales;
  final Route payment;
  final Route store;
  final Route officeInventory;
  final Route income;
  final Route expense;
  final Route incomingStock;
  final Route outgoingStock;

  const AppRoutes({

    this.login = const Route(name: "login", path: "/"),
    this.register = const Route(name: "register", path: "/register"),
    this.registerStore = const Route(name: "register/store", path: "/register/store"),
    this.stores = const Route(name: "stores", path: "/stores"),
    this.dashboard = const Route(name: "dashboard", path: "/dashboard"),
    this.notification = const Route(name: "notification", path: "/notification"),

    this.product = const Route(name: "product", path: "/product"),
    this.variant = const Route(name: "variant", path: "/variant"),
    this.packet = const Route(name: "packet", path: "/packet"),
    this.ingredient = const Route(name: "ingredient", path: "/ingredient"),
    this.discount = const Route(name: "discount", path: "/discount"),
    this.sales = const Route(name: "sales", path: "/sales"),
    this.payment = const Route(name: "payment", path: "/payment"),
    this.store = const Route(name: "store", path: "/store"),
    this.officeInventory = const Route(name: "officeInventory", path: "/officeInventory"),
    this.income = const Route(name: "income", path: "/income"),
    this.expense = const Route(name: "expense", path: "/expense"),
    this.incomingStock = const Route(name: "incoming_stock", path: "/incoming_stock"),
    this.outgoingStock = const Route(name: "outgoing_stock", path: "/outgoing_stock"),

  });
}

const appRoutes = AppRoutes();
