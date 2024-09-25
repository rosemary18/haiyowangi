import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:haiyowangi/src/index.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PacketsView extends StatefulWidget {
  const PacketsView({super.key});

  @override
  State<PacketsView> createState() => _PacketsViewState();
}

class _PacketsViewState extends State<PacketsView> {

  final _repository = PacketRepository();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<PacketModel> packets = [];
  int total = 0;
  int page = 1;
  int lastPage = 1;
  bool loading = true;
  bool loadmore = false;
  Timer? timeId;

  @override
  void initState() {
    super.initState();
    handlerGetData();
    _scrollController.addListener(_scrollListener);
  }

  // Handlers

  Future<void> handlerGetData() async {
    
    var state = context.read<AuthBloc>().state;
    final response = await _repository.getData("${state.store!.id}", queryParams: {"search_text": _searchController.text});

    total = 0;
    
    if (response.statusCode == 200) {
      packets.clear();
      for (var item in response.data!["data"]!["packets"]) {
        packets.add(PacketModel.fromJson(item));
      }
      total = response.data!["data"]!["total"];
      page = response.data!["data"]!["current_page"];
      lastPage = response.data!["data"]!["total_page"];
    }

    loading = false;
    setState(() {});
  }

  void handlerSearch(String v) async {

    setState(() {
      loading = true;
    });
    if (timeId?.isActive ?? false) timeId!.cancel();
    timeId = Timer(const Duration(milliseconds: 500), () {
      handlerGetData();
    });
  }

  void handlerLoadmore() async {

    var state = context.read<AuthBloc>().state;
    var res = await _repository.getData("${state.store!.id}", queryParams: {"page": page + 1, "search_text": _searchController.text});
    if (res.statusCode == 200) {  
      for (var item in res.data!["data"]!["packets"]) {
        packets.add(PacketModel.fromJson(item));
      }
      page = res.data!["data"]!["current_page"];
      lastPage = res.data!["data"]!["total_page"];
      loadmore = false;
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

  // Views

  Widget viewCard(BuildContext context, int index) {

    if (!loading && !loadmore && packets.isEmpty)  {
      return const SizedBox(
        height: 40,
        child: Center(
          child: Text("Paket tidak ditemukan!", style: TextStyle(color: greyTextColor, fontSize: 12)),
        ),
      );
    } 

    if (index == packets.length && loadmore)  {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LoadingAnimationWidget.threeArchedCircle(size: 24, color: primaryColor),
        ),
      );
    }

    if (loading) return const SkletonView(margin: EdgeInsets.only(bottom: 10), height: 60,);

    return TouchableOpacity(
      onPress: () async {
        var result = await context.pushNamed(appRoutes.detailPacket.name, extra: jsonEncode(packets[index]));
        if (result != null) {
          handlerGetData();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 0,
              blurRadius: 2,
              offset: const Offset(1, 1),
            ),
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(packets[index].name ?? "-", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
                Text("${packets[index].items.length} Item", style: const TextStyle(fontSize: 10, color: blueColor)),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: white1Color,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(top: 6),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Harga", style: TextStyle(fontSize: 8)),
                      Text(parseRupiahCurrency("${packets[index].price}"), style: const TextStyle(fontSize: 8))
                    ],
                  ),
                  const Divider(color: greyLightColor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Dijual", style: TextStyle(fontSize: 8)),
                      Text(packets[index].isPublished! ? "Ya" : "Tidak", style: const TextStyle(fontSize: 8)),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white1Color,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 12, right: 12, bottom: 0),
            child: Text("Daftar Paket ($total)", style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: Container(
              height: double.infinity,
              width: double.infinity,
              color: white1Color,
              child: RefreshIndicator(
                onRefresh: handlerGetData,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: loading ? 3 : loadmore ? packets.length + 1 : packets.isNotEmpty ? packets.length : 1,
                  itemBuilder: viewCard,
                  padding: const EdgeInsets.all(12),
                  physics: const AlwaysScrollableScrollPhysics(),
                ), 
              ),
            )
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: InputSearch(
                    controller: _searchController,
                    onChanged: handlerSearch,
                  )
                ),
                TouchableOpacity(
                  onPress: () async {
                    var result = await context.pushNamed(appRoutes.formPacket.name);
                    if (result != null) {
                      handlerGetData();
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 1, offset: Offset(0, 1))
                      ]
                    ),
                    margin: const EdgeInsets.only(left: 12),
                    child: const Icon(CupertinoIcons.plus, color: Colors.white, size: 20),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}