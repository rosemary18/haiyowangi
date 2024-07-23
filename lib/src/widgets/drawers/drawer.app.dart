import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  Widget buildMenuItem(BuildContext context, r) {

    return TouchableOpacity(
      onPress: () {
        Navigator.pop(context);
        context.go(r?.routePath);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.close, color: blackColor),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text("${r?.title!}"),
              )
            ),
            if (r is IDRouteGroup) const Icon(Icons.arrow_drop_down_outlined, color: greyDarkColor)
          ],
        )
      ), 
    );
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint(drawerRoutes);
    return Scaffold(
      body: Container(
        color: Colors.white,
        height: double.infinity,
        width: double.infinity,
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            
          },
          builder: (context, state) => Column(
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
                            "Terakhir sinkronasi: ${state.store!.lastSync!.isEmpty ? "-" : state.store!.lastSync!}",
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
                                onPress: () { close(); },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.storefront, color: blackColor, size: 16),
                                    SizedBox(width: 10),
                                    Text("Toko", style: TextStyle(color: blackColor, fontWeight: FontWeight.w500, fontSize: 14)),
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
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TouchableOpacity(
                          onPress: () {
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 6, right: 6, top: 6),
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Semua Toko"),
                                Text("12"),
                              ],
                            )
                          ), 
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(color: greyLightColor, height: 1, indent: 12, endIndent: 12),
                        ),
                        for (final r in drawerRoutes.routes) buildMenuItem(context, r)
                      ],
                    ),
                  ),
                )
              )
            ],
          )
        )
      )
    );
  }
}