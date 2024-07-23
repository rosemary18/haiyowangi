abstract class IDRouteBase {}

class IDRoute implements IDRouteBase {

  final String name;
  final String title;
  final String routePath;

  const IDRoute({
    required this.name,
    required this.title,
    required this.routePath
  });

}

class IDRouteGroup implements IDRouteBase {

  final String name;
  final String title;
  final List<IDRoute> routes;

  const IDRouteGroup({
    required this.name,
    required this.title,
    required this.routes
  });
}

class DRoute {

  final List<IDRouteBase> routes;

  const DRoute({
    this.routes = const [
      IDRoute(
        name: "dashboard", 
        title: "Beranda",
        routePath: "/dashboard"
      ),
      IDRouteGroup(
        name: "product", 
        title: "Produk",
        routes: [
          IDRoute(name: "product", title: "Produk", routePath: "/product"),
          IDRoute(name: "variant", title: "Varian", routePath: "/variant"),
          IDRoute(name: "packet", title: "Paket", routePath: "/packet"),
          IDRoute(name: "ingredient", title: "Bahan", routePath: "/ingredient"),
        ]
      ),
      IDRouteGroup(
        name: "inventory", 
        title: "Inventori",
        routes: [
          IDRoute(name: "incoming_stock", title: "Stok Masuk", routePath: "/incoming_stock"),
          IDRoute(name: "outgoing_stock", title: "Stok Keluar", routePath: "/outgoing_stock"),
        ]
      ),
      IDRouteGroup(
        name: "marketing", 
        title: "Marketing",
        routes: [
          IDRoute(name: "discount", title: "Diskon", routePath: "/discount"),
        ]
      ),
      IDRouteGroup(
        name: "sales", 
        title: "Penjualan",
        routes: [
          IDRoute(name: "sales", title: "Penjualan", routePath: "/sales"),
          IDRoute(name: "payment", title: "Pembayaran", routePath: "/payment")
        ]
      ),
      IDRouteGroup(
        name: "inex", 
        title: "Pendapatan & Pengeluaran",
        routes: [
          IDRoute(name: "income", title: "Pendapatan", routePath: "/income"),
          IDRoute(name: "expense", title: "Pengeluaran", routePath: "/expense"),
        ]
      ),
      IDRouteGroup(
        name: "store", 
        title: "Toko",
        routes: [
          IDRoute(name: "store", title: "Toko", routePath: "/store"),
          IDRoute(name: "officeInventory", title: "Inventaris Kantor", routePath: "/officeInventory"),
        ]
      )
    ]
  });
}

const drawerRoutes = DRoute();