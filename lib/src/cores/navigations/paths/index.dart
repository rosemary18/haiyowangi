import 'base_interface.dart';

class AppRoutes {
  
  final Route login;
  final Route register;
  final Route registerStore;
  final Route stores;

  final Route account;
  final Route dashboard;
  final Route notification;
  final Route yourstores;

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
  final Route staff;

  final Route formOfficeInventory;
  final Route detailOfficeInventory;

  final Route formIncome;
  final Route detailIncome;

  final Route formExpense;
  final Route detailExpense;

  final Route formStaff;
  final Route detailStaff;

  const AppRoutes({

    this.login = const Route(name: "login", path: "/"),
    this.register = const Route(name: "register", path: "/register"),
    this.registerStore = const Route(name: "register/store", path: "/register/store"),
    this.stores = const Route(name: "stores", path: "/stores"),
    this.dashboard = const Route(name: "dashboard", path: "/dashboard"),
    this.account = const Route(name: "account", path: "/account"),
    this.notification = const Route(name: "notification", path: "/notification"),
    this.yourstores = const Route(name: "yourstores", path: "/yourstores"),

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
    this.staff = const Route(name: "staff", path: "/staff"),

    this.formOfficeInventory = const Route(name: "form_office_inventory", path: "/form_office_inventory"),
    this.detailOfficeInventory = const Route(name: "detail_office_inventory", path: "/detail_office_inventory"),

    this.formIncome = const Route(name: "form_income", path: "/form_income"),
    this.detailIncome = const Route(name: "detail_income", path: "/detail_income"),

    this.formExpense = const Route(name: "form_expense", path: "/form_expense"),
    this.detailExpense = const Route(name: "detail_expense", path: "/detail_expense"),

    this.formStaff = const Route(name: "form_staff", path: "/form_staff"),
    this.detailStaff = const Route(name: "detail_staff", path: "/detail_staff"),

  });
}

const appRoutes = AppRoutes();
