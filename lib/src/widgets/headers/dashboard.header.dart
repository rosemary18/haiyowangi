import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:haiyowangi/src/index.dart';

class DashboardHeader extends StatelessWidget implements PreferredSizeWidget {

  final String title;

  const DashboardHeader({
    super.key,
    this.title = 'Dashboard',
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: primaryColor,
        title: Text(
          title, 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        shadowColor: Colors.black,
        centerTitle: false,
        elevation: .5,
        automaticallyImplyLeading: false,
        titleSpacing: 8,
        leadingWidth: 40,
        leading: Container(
          margin: const EdgeInsets.only(left: 12, bottom: 4),
          child: Row(
            children: [
              TouchableOpacity(
                onPress: () {
                  Scaffold.of(context).openDrawer();
                },
                child: const Icon(
                  Icons.menu, 
                  color: Colors.white,
                  size: 24,
                ),
              )
            ]
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, bottom: 4),
            child: Row(
              children: [
                TouchableOpacity(
                  onPress: () => context.pushNamed(appRoutes.notification.name),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: GoRouter.of(context).routeInformationProvider.value.uri.toString() == appRoutes.notification.path ? const Color.fromARGB(12, 0, 0, 0) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Stack(
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        BlocConsumer<AuthBloc, AuthState>(
                          listener: (c, s) {},
                          builder: (c, s) {
                            if (s.unreadNotification > 0) {
                              return const Positioned(
                                top: 2,
                                right: 2,
                                child: Dot()
                              );
                            }
                            return const SizedBox();
                          }
                        )
                      ]
                    ),
                  ),
                )
              ]
            ),
          )
        ],
      );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(40);
}