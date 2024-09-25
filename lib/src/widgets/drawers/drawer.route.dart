import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';

abstract class IDRouteBase {
  
}

class IDRoute implements IDRouteBase {

  final String name;
  final String title;
  final String routePath;
  final IconData? icon;

  const IDRoute({
    required this.name,
    required this.title,
    required this.routePath,
    this.icon
  });

}

class IDRouteGroup implements IDRouteBase {

  final String name;
  final String title;
  final IconData? icon;
  final List<IDRoute> routes;

  const IDRouteGroup({
    required this.name,
    required this.title,
    this.icon,
    required this.routes
  });
}

class DRoute {

  final List<IDRouteBase> routes;

  const DRoute({
    this.routes = const [
      IDRoute(
        name: "dashboard", 
        title: "✨  Insight",
        routePath: "/dashboard"
      ),
      IDRouteGroup(
        name: "product", 
        title: "Produk",
        icon: Boxicons.bxs_package,
        routes: [
          IDRoute(name: "product", title: "Produk", routePath: "/product"),
          IDRoute(name: "ingredient", title: "Bahan", routePath: "/ingredient"),
          IDRoute(name: "packet", title: "Paket", routePath: "/packet"),
        ]
      ),
      IDRouteGroup(
        name: "inventory", 
        title: "Inventori",
        icon: Boxicons.bx_data,
        routes: [
          IDRoute(name: "incoming_stock", title: "Stok Masuk", routePath: "/incoming_stock"),
          IDRoute(name: "outgoing_stock", title: "Stok Keluar", routePath: "/outgoing_stock"),
        ]
      ),
      IDRouteGroup(
        name: "marketing", 
        title: "Marketing",
        icon: Boxicons.bx_news,
        routes: [
          IDRoute(name: "discount", title: "Diskon", routePath: "/discount"),
        ]
      ),
      IDRouteGroup(
        name: "sales", 
        title: "Penjualan",
        icon: Boxicons.bx_shopping_bag,
        routes: [
          IDRoute(name: "sales", title: "Penjualan", routePath: "/sales"),
          // IDRoute(name: "payment", title: "Pembayaran", routePath: "/payment")
        ]
      ),
      IDRouteGroup(
        name: "inex", 
        title: "Pendapatan & Pengeluaran",
        icon: Boxicons.bx_book_bookmark,
        routes: [
          IDRoute(name: "income", title: "Pendapatan", routePath: "/income"),
          IDRoute(name: "expense", title: "Pengeluaran", routePath: "/expense"),
        ]
      ),
      IDRouteGroup(
        name: "store", 
        title: "Toko",
        icon: Boxicons.bx_store,
        routes: [
          IDRoute(name: "store", title: "Toko", routePath: "/store"),
          IDRoute(name: "officeInventory", title: "Inventaris", routePath: "/officeInventory"),
          IDRoute(name: "staff", title: "Staff", routePath: "/staff"),
        ]
      )
    ]
  });
}


const drawerRoutes = DRoute();

IDRoute? getDrawerRoute(String path) {

  IDRoute? route;

  for (var r in drawerRoutes.routes) {
    if (r is IDRouteGroup) {
      for (var rr in r.routes) {
        if (rr.routePath == path) {
          route = rr;
          break;
        }
      }
    } else if (r is IDRoute && r.routePath == path) {
      route = r;
      break;
    }
  }

  return route;
}