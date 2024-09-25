import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:haiyowangi/src/index.dart';
import 'package:haiyowangi/src/widgets/drawers/drawer.route.dart';
class DrawerGroupedShell extends StatefulWidget {

  final Widget child;
  final GoRouterState state;

  const DrawerGroupedShell({super.key, required this.child, required this.state});

  @override
  State<DrawerGroupedShell> createState() => _DrawerGroupedShellState();
}

class _DrawerGroupedShellState extends State<DrawerGroupedShell> {

  String title = "";

  @override
  void initState() {
    super.initState();
    setState(setTitle);
  }

  @override
  void didUpdateWidget(covariant DrawerGroupedShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(setTitle);
  }

  void setTitle() {
    var state = context.read<AuthBloc>().state;
    if (widget.state.fullPath == appRoutes.notification.path) {
      title = "Notifikasi";
    } else if (widget.state.fullPath == appRoutes.account.path) {
      title = "Akun";
    } else if (widget.state.fullPath == appRoutes.yourstores.path) {
      title = "Toko Anda (${state.user?.stores?.length ?? 0})";
    } else  {
      title = getDrawerRoute("${widget.state.fullPath}")?.title ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: const Drawer(
        width: 300,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(18)),
        ),
        child: DrawerApp(),
      ),
      appBar: DashboardHeader(title: title),
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            color: const Color(0xFF0D0D0D),
            child: widget.child,
          ),
        ],
      )
    );
  }
}