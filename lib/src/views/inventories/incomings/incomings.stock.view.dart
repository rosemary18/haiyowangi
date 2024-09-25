import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:go_router/go_router.dart';
import 'package:haiyowangi/src/index.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class IncomingsStockView extends StatefulWidget {
  const IncomingsStockView({super.key});

  @override
  State<IncomingsStockView> createState() => _IncomingsStockViewState();
}

class _IncomingsStockViewState extends State<IncomingsStockView> {

  final _repository = IncomingStockRepository();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  List<IncomingStockModel> incomingsStock = [];
  int total = 0;
  int page = 1;
  int lastPage = 1;
  bool loading = true;
  bool loadmore = false;
  Timer? timeId;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat("yyyy-MM-dd").format(DateTime.now());
    handlerGetData();
    _scrollController.addListener(_scrollListener);
  }

  // Handlers

  Map<String, String> genQueryParams() {

    final queryParams = {"search_text": _searchController.text};

    if (_dateController.text.isNotEmpty) {
      List<String> date = _dateController.text.split(" - ");
      queryParams["start_date"] = date[0];
      queryParams["end_date"] = date.length > 1 ? date[1] : date[0];
    }

    return queryParams;
  }

  Future<void> handlerGetData() async {
    
    var state = context.read<AuthBloc>().state;
    final response = await _repository.getData("${state.store!.id}", queryParams: genQueryParams());

    total = 0;
    
    if (response.statusCode == 200) {
      incomingsStock.clear();
      for (var item in response.data!["data"]!["incomings_stock"]) {
        incomingsStock.add(IncomingStockModel.fromJson(item));
      }
      total = response.data!["data"]!["total"] ?? 0;
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
    var res = await _repository.getData("${state.store!.id}", queryParams: {"page": page + 1, ...genQueryParams()});
    if (res.statusCode == 200) {  
      for (var item in res.data!["data"]!["incomings_stock"]) {
        incomingsStock.add(IncomingStockModel.fromJson(item));
      }
      page = res.data!["data"]!["current_page"];
      lastPage = res.data!["data"]!["total_page"];
      loadmore = false;
      setState(() {});
    }
  }

  Future<void> deleteData(String id) async {
    
    final response = await _repository.delete(id);
    
    if (response.statusCode == 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Stok masuk berhasil di hapus!"),
          backgroundColor: Colors.green,
        ),
      );
      handlerGetData();
      setState(() {
        incomingsStock.removeWhere((element) => element.id.toString() == id);
      });
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

  void viewDeleteConfirm(int i) {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          content: Text("Apakah anda yakin ingin menghapus stok masuk ${incomingsStock[i].code}?"),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          scrollable: true,
          shadowColor: primaryColor.withOpacity(0.2),
          insetPadding: EdgeInsets.symmetric(horizontal: isTablet ? MediaQuery.of(context).size.width/4 : 16),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          actions: [
            TouchableOpacity(
              onPress: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: greyColor,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Text(
                  'Batal', 
                  style: TextStyle(
                    color: Color.fromARGB(192, 0, 0, 0), 
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                  )
                ),
              ), 
            ),
            TouchableOpacity(
              onPress: () async {
                Navigator.pop(context);
                deleteData(incomingsStock[i].id.toString());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(left: 6),
                decoration: BoxDecoration(
                  color: redColor,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Text(
                  'Hapus', 
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                  )
                ),
              ), 
            )
          ],
        );
      }
    );
  }

  Widget viewCard(BuildContext context, int index) {

    if (!loading && !loadmore && incomingsStock.isEmpty)  {
      return const SizedBox(
        height: 40,
        child: Center(
          child: Text("Stok masuk tidak ditemukan!", style: TextStyle(color: greyTextColor, fontSize: 12)),
        ),
      );
    } 

    if (index == incomingsStock.length && loadmore)  {
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
        var result = await context.pushNamed(appRoutes.detailIncomingStock.name, extra: jsonEncode(incomingsStock[index]));
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
                    Text("#${incomingsStock[index].code ?? "-"}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Text(formatDateFromString("${incomingsStock[index].createdAt}", format: "EEEE, dd/MM/yyyy, HH:mm"), style: const TextStyle(fontSize: 8, color: greyTextColor)),
                  ],
                ),
                if (!(incomingsStock[index].status == 1))TouchableOpacity(
                  child: const Icon(
                    Boxicons.bxs_trash,
                    color: redColor,
                    size: 14
                  ), 
                  onPress: () => viewDeleteConfirm(index)
                )
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
                      const Text("Nama", style: TextStyle(fontSize: 8)),
                      Text(incomingsStock[index].name ?? "-", style: const TextStyle(fontSize: 8))
                    ],
                  ),
                  const Divider(color: greyLightColor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Status", style: TextStyle(fontSize: 8)),
                      Text(incomingsStock[index].status == 1 ? "Posted" : "Pending", style: TextStyle(fontSize: 8, color: (incomingsStock[index].status == 1) ? blueColor : yellowColor)),
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
          InputDate(
            range: true,
            controller: _dateController,
            onChanged: (v) => handlerGetData(),
            margin: const EdgeInsets.only(left: 12, right: 12, top: 12),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text("Daftar Stok Masuk ($total)", style: const TextStyle(fontSize: 12)),
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
                  itemCount: loading ? 3 : loadmore ? incomingsStock.length + 1 : incomingsStock.isNotEmpty ? incomingsStock.length : 1,
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
                    var result = await context.pushNamed(appRoutes.formIncomingStock.name);
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