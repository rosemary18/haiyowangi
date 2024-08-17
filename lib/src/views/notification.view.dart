import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haiyowangi/src/index.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {

  final NotificationRepository _notificationRepo = NotificationRepository();
  final ScrollController _scrollController = ScrollController();
  final List<NotificationModel> _notifications = [];

  bool loadmore = false;
  int page = 0;
  int lastPage = 0;


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    handlerGetNotifications();
  }

  Future<void> handlerGetNotifications() async {

    final state = context.read<AuthBloc>().state;
    var res = await _notificationRepo.getNotifications("${state.store!.id}");

    if (res.statusCode == 200) {
      setState(() {
        _notifications.clear();
        for (var item in res.data!["data"]!["notifications"]) {
          _notifications.add(NotificationModel.fromJson(item));
        }
        page = res.data!["data"]!["current_page"];
        lastPage = res.data!["data"]!["total_page"];
      });
    }
  }

  void handlerLoadmore() async {

    var state = context.read<AuthBloc>().state;
    var res = await _notificationRepo.getNotifications("${state.store!.id}", page: page + 1);
    if (res.statusCode == 200) {  
      for (var item in res.data!["data"]!["notifications"]) {
        _notifications.add(NotificationModel.fromJson(item));
      }
      page = res.data!["data"]!["current_page"];
      lastPage = res.data!["data"]!["total_page"];
      loadmore = false;
      setState(() {});
    }
  }

  void handlerReadAll() async {
    
    var state = context.read<AuthBloc>().state;
    var res = await _notificationRepo.readAll("${state.store!.id}");
    if (res.statusCode == 200) {
      state.unreadNotification = 0;
      context.read<AuthBloc>().add(AuthUpdateState(state: state));
      for (var item in _notifications) {
        item.isRead = true;
      }
      setState(() {});
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (page < lastPage && !loadmore) {
        setState(() {
          loadmore = true;
        });
        handlerLoadmore();
      }
    }
  }

  void handlerDeleteNotification(int index) async {

    rootNavigatorKey.currentState?.pop();
    Timer(const Duration(milliseconds: 350), () async {
      var res = await _notificationRepo.delete("${_notifications[index].id}");
      if (res.statusCode == 200) {
        _notifications.removeAt(index);
        setState(() {});
      }
    });
  }

  void handlerDeleteAllNotification() async {

    var state = context.read<AuthBloc>().state;
    var res = await _notificationRepo.deleteByStore("${state.store!.id}");
    if (res.statusCode == 200) {
      _notifications.clear();
      setState(() {});
    }
  }

  // Views

  void viewNotificationDetail(int index, BuildContext ctx) async {

    var res = await _notificationRepo.read("${_notifications[index].id}");
    if (res.statusCode == 200) {
      _notifications[index].isRead = true;
      setState(() {});
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_notifications[index].title!, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
          titlePadding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 10),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12), 
                child: Text(
                  _notifications[index].message!, 
                  style: const TextStyle(color: Colors.black, fontSize: 14)
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          scrollable: true,
          shadowColor: primaryColor.withOpacity(0.2),
          insetPadding: EdgeInsets.symmetric(horizontal: isTablet ? MediaQuery.of(context).size.width/4 : 16),
          actions: [
            TouchableOpacity(
              onPress: () => handlerDeleteNotification(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: redLightColor,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Text(
                  'Hapus', 
                  style: TextStyle(
                    color: redColor, 
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                  )
                ),
              ), 
            ),
          ],
        );
      },
    );
  }

  Widget notificationCard(int index) {

    if (!loadmore && _notifications.isEmpty)  {
      return const SizedBox(
        height: 40,
        child: Center(
          child: Text("Notifikasi tidak ditemukan!", style: TextStyle(color: greyTextColor, fontSize: 12)),
        ),
      );
    } 

    if (index == _notifications.length)  {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LoadingAnimationWidget.threeArchedCircle(size: 24, color: primaryColor),
        ),
      );
    }

    return TouchableOpacity(
      onPress: () {
        viewNotificationDetail(index, context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_notifications[index].title!, style: TextStyle(fontSize: 12, color: _notifications[index].isRead! ? greyDarkColor : blackColor, fontWeight: FontWeight.w600)),
                  Text(_notifications[index].message!, style: const TextStyle(fontSize: 11, color: greyDarkColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              )
            ),
            Text(_notifications[index].createdAt!.isEmpty ? "" : DateFormat('dd/MM/yy, kk:mm').format(DateTime.parse(_notifications[index].createdAt!)), style: TextStyle(fontSize: 11, color: _notifications[index].isRead! ? greyDarkColor : Colors.green.shade300)),
          ]
        ),
      ), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Semua Notifikasi", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color.fromARGB(221, 43, 43, 43))),
                  BlocConsumer<AuthBloc, AuthState>(
                    listener: (c, s) {},
                    builder: (c, s) {
                      if (s.unreadNotification > 0) {
                        return TouchableOpacity(
                          onPress: handlerReadAll,
                          child: const Text("Tandai Terbaca", style: TextStyle(fontSize: 12, color: blueColor, decoration: TextDecoration.underline, decorationColor: blueColor)), 
                        );
                      } else if (_notifications.isNotEmpty){ 
                        return TouchableOpacity(
                          onPress: handlerDeleteAllNotification,
                          child: const Text("Hapus Semua", style: TextStyle(fontSize: 12, color: blueColor, decoration: TextDecoration.underline, decorationColor: blueColor)), 
                        );
                      }

                      return const SizedBox();
                    }, 
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                strokeWidth: 2,
                color: primaryColor,
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                onRefresh: handlerGetNotifications,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _notifications.isEmpty ? 1 : _notifications.length + (loadmore ? 1 : 0),
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom + 12),
                  itemBuilder: (context, index) => notificationCard(index),
                ),
              ),
            )
          ],
        )
      ),
    );
  }
}