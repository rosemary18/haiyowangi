import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:go_router/go_router.dart';
import 'package:haiyowangi/src/index.dart';
import 'drawer.route.dart';

class DrawerApp extends StatefulWidget {
  const DrawerApp({super.key});

  @override
  State<DrawerApp> createState() => _DrawerAppState();
}

class _DrawerAppState extends State<DrawerApp> {

  @override
  void initState() {
    super.initState();
  }

  void handlerLogout(BuildContext context, VoidCallback close) {

    close();
    Navigator.pop(context);
    context.read<AuthBloc>().add(AuthLogout());
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            
          },
          builder: (context, state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(minHeight: 40 + MediaQuery.of(context).viewPadding.top),
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: EdgeInsets.only(top: 8 + MediaQuery.of(context).viewPadding.top, left: 8, right: 8, bottom: 8),
                decoration: const BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  )
                ),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      height: 38,
                      width: 38,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        color: white1Color,
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                      child: state.store!.storeImage!.isEmpty ? 
                            Center(
                              child: Text(state.store!.name!.substring(0, 1).toUpperCase()),
                            ) : Image.network(state.store!.storeImage!, fit: BoxFit.cover),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.store!.name!.isEmpty ? "-" : state.store!.name!,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "Terakhir sinkronasi: ${state.store!.lastSync!.isEmpty ? "-" : formatDateFromString(state.store!.lastSync!)}",
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                          )
                        ],
                      )
                    ),

                    PopUpContent(
                      contentBuilder: (context, close) => Material(
                        borderRadius: const BorderRadius.all(Radius.circular(6)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            boxShadow: [
                              BoxShadow(color: Color.fromARGB(20, 0, 0, 0), blurRadius: 8, spreadRadius: 4)
                            ]
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TouchableOpacity(
                                onPress: () { 
                                  close();
                                  Navigator.pop(context);
                                  context.goNamed(appRoutes.account.name); 
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Boxicons.bx_user, color: blackColor, size: 16),
                                    SizedBox(width: 10),
                                    Text("Akun", style: TextStyle(color: blackColor, fontWeight: FontWeight.w500, fontSize: 14)),
                                  ],
                                ), 
                              ),
                              const SizedBox(height: 12),
                              TouchableOpacity(
                                onPress: () { 
                                  close();
                                  Navigator.pop(context);
                                  context.goNamed(appRoutes.yourstores.name); 
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.storefront, color: blackColor, size: 16),
                                    SizedBox(width: 10),
                                    Text("Toko Anda", style: TextStyle(color: blackColor, fontWeight: FontWeight.w500, fontSize: 14)),
                                  ],
                                ), 
                              ),
                              const SizedBox(height: 12),
                              TouchableOpacity(
                                onPress: () => handlerLogout(context, close),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.logout, color: redColor, size: 16),
                                    SizedBox(width: 10),
                                    Text("Keluar", style: TextStyle(color: redColor, fontWeight: FontWeight.w500, fontSize: 14)),
                                  ],
                                ), 
                              )
                            ],
                          ),
                        ),
                      ),
                      child: const Icon(Icons.more_vert, color: white1Color),
                    ),

                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(top: 10, bottom: MediaQuery.of(context).viewPadding.bottom),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final r in drawerRoutes.routes) DMenu(menu: r),
                      ],
                    ),
                  ),
                )
              ),
              Container(
                padding: EdgeInsets.only(left: 12, top: 12, right: 12, bottom: MediaQuery.of(context).viewPadding.bottom + 12),
                child: const Text("©2024 Haiyo Wangi. All rights reserved", style: TextStyle(color: blackColor, fontSize: 8, fontWeight: FontWeight.w500)),
              )
            ],
          )
        )
      )
    );
  }
}

class DMenu extends StatefulWidget {

  final dynamic menu;

  const DMenu({super.key, required this.menu});

  @override
  State<DMenu> createState() => _DMenuState();
}

class _DMenuState extends State<DMenu> {

  bool isExpanded = false;
  String? activePath;

  @override
  void initState() {
    super.initState();
    
    if (widget.menu is IDRoute) {
      if (widget.menu.routePath == GoRouter.of(context).routeInformationProvider.value.uri.toString()) {
        setState(() {
          activePath = widget.menu.routePath;
        });
      }
    } else if (widget.menu is IDRouteGroup) {
      for (final r in widget.menu.routes) {
        if (r is IDRoute && r.routePath == GoRouter.of(context).routeInformationProvider.value.uri.toString()) {
          setState(() {
            isExpanded = true;
            activePath = r.routePath;
          });
          break;
        }
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      onPress: () {
        if (widget.menu is IDRouteGroup) {
          setState(() {
            isExpanded = !isExpanded;
          });
        } else {
          Navigator.pop(context);
          context.go(widget.menu?.routePath);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        color: (widget.menu is IDRoute && widget.menu.routePath == activePath) ? greenLightColor : Colors.transparent,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.menu?.icon != null) Icon(widget.menu?.icon, color: (widget.menu is IDRoute && widget.menu.routePath == activePath) ? primaryColor : blackColor),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text("${widget.menu?.title!}", style: TextStyle(color: (widget.menu is IDRoute && widget.menu.routePath == activePath) ? primaryColor : blackColor, fontWeight: FontWeight.w500, fontSize: 14)),
                    )
                  ),
                  if (widget.menu is IDRouteGroup) Icon(isExpanded ? Icons.arrow_drop_up_outlined : Icons.arrow_drop_down_outlined, color: isExpanded ? primaryColor : greyDarkColor)
                ],
              ),
            ),
            if (isExpanded && (widget.menu is IDRouteGroup)) Container(
              margin: const EdgeInsets.only(top: 4, left: 8, right: 8),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: white1Color,
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                children: [
                  for (final r in widget.menu.routes) TouchableOpacity(
                    onPress: () {
                      Navigator.pop(context);
                      context.go(r.routePath);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                      height: 40,
                      color: (r.routePath == activePath) ? greenLightColor : Colors.transparent,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (r.icon != null) Icon(r.icon, color: blackColor),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(r.title, style: TextStyle(color: (r.routePath == activePath) ? primaryColor : blackColor, fontWeight: FontWeight.w500, fontSize: 14)),
                            )
                          ),
                        ],
                      ),
                    ), 
                  ),
                ],
              ),
            )
          ],
        )
      ), 
    );
  }
}