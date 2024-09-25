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

  final Route formProduct;
  final Route detailProduct;
  final Route editProduct;
  final Route copyProduct;

  final Route formOfficeInventory;
  final Route detailOfficeInventory;

  final Route formIncome;
  final Route detailIncome;

  final Route formExpense;
  final Route detailExpense;

  final Route formStaff;
  final Route detailStaff;

  final Route formIngredient;
  final Route detailIngredient;

  final Route formPacket;
  final Route detailPacket;

  final Route formVariant;
  final Route detailVariant;
  final Route editVariant;
  final Route manageVariant;

  final Route formIncomingStock;
  final Route detailIncomingStock;

  final Route formOutgoingStock;
  final Route detailOutgoingStock;

  final Route formDiscount;
  final Route detailDiscount;

  final Route detailSale;
  final Route detailPayment;

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

    this.formProduct = const Route(name: "form_product", path: "/form_product"),
    this.detailProduct = const Route(name: "detail_product", path: "/detail_product"),
    this.editProduct = const Route(name: "edit_product", path: "/edit_product"),
    this.copyProduct = const Route(name: "copy_product", path: "/copy_product"),

    this.formOfficeInventory = const Route(name: "form_office_inventory", path: "/form_office_inventory"),
    this.detailOfficeInventory = const Route(name: "detail_office_inventory", path: "/detail_office_inventory"),

    this.formIncome = const Route(name: "form_income", path: "/form_income"),
    this.detailIncome = const Route(name: "detail_income", path: "/detail_income"),

    this.formExpense = const Route(name: "form_expense", path: "/form_expense"),
    this.detailExpense = const Route(name: "detail_expense", path: "/detail_expense"),

    this.formStaff = const Route(name: "form_staff", path: "/form_staff"),
    this.detailStaff = const Route(name: "detail_staff", path: "/detail_staff"),

    this.formIngredient = const Route(name: "form_ingredient", path: "/form_ingredient"),
    this.detailIngredient = const Route(name: "detail_ingredient", path: "/detail_ingredient"),

    this.formPacket = const Route(name: "form_packet", path: "/form_packet"),
    this.detailPacket = const Route(name: "detail_packet", path: "/detail_packet"),

    this.formVariant = const Route(name: "form_variant", path: "/form_variant"),
    this.editVariant = const Route(name: "edit_variant", path: "/edit_variant"),
    this.detailVariant = const Route(name: "detail_variant", path: "/detail_variant"),
    this.manageVariant = const Route(name: "manage_variant", path: "/manage_variant"),

    this.formIncomingStock = const Route(name: "form_incoming_stock", path: "/form_incoming_stock"),
    this.detailIncomingStock = const Route(name: "detail_incoming_stock", path: "/detail_incoming_stock"),

    this.formOutgoingStock = const Route(name: "form_outgoing_stock", path: "/form_outgoing_stock"),
    this.detailOutgoingStock = const Route(name: "detail_outgoing_stock", path: "/detail_outgoing_stock"),

    this.formDiscount = const Route(name: "form_discount", path: "/form_discount"),
    this.detailDiscount = const Route(name: "detail_discount", path: "/detail_discount"),

    this.detailSale = const Route(name: "detail_sale", path: "/detail_sale"),
    this.detailPayment = const Route(name: "detail_payment", path: "/detail_payment"),

  });
}

const appRoutes = AppRoutes();
