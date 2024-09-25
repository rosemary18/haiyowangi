import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:go_router/go_router.dart';
import 'package:haiyowangi/src/index.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'widgets/index.dart';

class SalesView extends StatefulWidget {

  const SalesView({super.key});

  @override
  State<SalesView> createState() => _SalesViewState();
}

class _SalesViewState extends State<SalesView> {

  final _repository = SalesRepository();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  PersistentBottomSheetController? _sheetController;

  List<SaleModel> sales = [];
  int total = 0;
  int page = 1;
  int lastPage = 1;
  bool loading = true;
  bool loadmore = false;
  Timer? timeId;

  Map<String, dynamic> filter = {};

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat("yyyy-MM-dd").format(DateTime.now());
    handlerGetData();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _sheetController?.close();
    timeId?.cancel();
    super.dispose();
  }

  // Handlers

  Map<String, dynamic> genQueryParams() {

    final queryParams = {
      "search_text": _searchController.text,
      ...filter
    };
    if (_dateController.text.isNotEmpty) {
      List<String> date = _dateController.text.split(" - ");
      queryParams["start_date"] = date[0];
      queryParams["end_date"] = date.length > 1 ? date[1] : date[0];
    }

    return queryParams;
  }

  Future<void> handlerGetData() async {
    
    var state = context.read<AuthBloc>().state;
    final response = await _repository.getData(
      "${state.store!.id}", 
      queryParams: genQueryParams()
    );

    total = 0;
    
    if (response.statusCode == 200) {
      sales.clear();
      for (var item in response.data!["data"]!["sales"]) {
        sales.add(SaleModel.fromJson(item));
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
      for (var item in res.data!["data"]!["sales"]) {
        sales.add(SaleModel.fromJson(item));
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
          content: Text("Penjualan berhasil di hapus!"),
          backgroundColor: Colors.green,
        ),
      );
      handlerGetData();
      setState(() {
        sales.removeWhere((element) => element.id.toString() == id);
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

  void handlerFilter(Map<String, dynamic> v) {

    setState(() {
      filter = v;
    });
    handlerGetData();
  }

  void handlerCreateSales() async {
    
    final data = {
      "store_id": context.read<AuthBloc>().state.store!.id,
    };

    Response response = await _repository.create(data);

    if (response.statusCode == 200) {
      var result = await context.pushNamed(appRoutes.detailSale.name, extra: jsonEncode(response.data!["data"]));
      if (result != null) {
        handlerGetData();
      }
    }
  }

  // Views

  void viewFilter() {

    if (_sheetController == null) {
      _sheetController = showBottomSheet(
        context: context,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .65),
        clipBehavior: Clip.none,
        builder: (context) => FilterSalesView(filter: filter, controller: _sheetController, onFilter: handlerFilter),
      );
      _sheetController!.closed.whenComplete(() {
        Timer(const Duration(milliseconds: 350), () {
          _sheetController = null;
          setState(() {});
        });
      });
    } else {
      _sheetController!.setState!(() {});
    }

    setState(() {});
  }

  void viewDeleteConfirm(int i) {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          content: Text("Apakah anda yakin ingin menghapus penjualan #${sales[i].code}?"),
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
                deleteData(sales[i].id.toString());
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

    if (!loading && !loadmore && sales.isEmpty)  {
      return const SizedBox(
        height: 40,
        child: Center(
          child: Text("Penjualan tidak ditemukan!", style: TextStyle(color: greyTextColor, fontSize: 12)),
        ),
      );
    } 

    if (index == sales.length && loadmore)  {
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
        var result = await context.pushNamed(appRoutes.detailSale.name, extra: jsonEncode(sales[index]));
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "#${sales[index].code!.isNotEmpty ? sales[index].code : "-"}", 
                        style: const TextStyle(
                          fontSize: 14, 
                          fontWeight: FontWeight.w600
                        ),
                        maxLines: 2, 
                        overflow: TextOverflow.ellipsis
                      ),
                      Text(formatDateFromString(sales[index].createdAt!, format: 'EEEE, dd/MM/yyyy'), style: const TextStyle(fontSize: 8, color: greyTextColor)),
                    ],
                  )
                ),
                if (sales[index].status == 0) TouchableOpacity(
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
                      const Text("Status", style: TextStyle(fontSize: 8)),
                      Text(
                        sales[index].status == 0 ? "Pending" : sales[index].status == 1 ? "Selesai" : "Dibatalkan", 
                        style: TextStyle(fontSize: 8, color: sales[index].status == 0 ? blackColor : sales[index].status == 1 ? Colors.green : redColor)
                      )
                    ],
                  ),
                  const Divider(color: greyLightColor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total", style: TextStyle(fontSize: 8)),
                      Text(parseRupiahCurrency("${sales[index].total ?? 0}"), style: const TextStyle(fontSize: 8))
                    ],
                  ),
                  const Divider(color: greyLightColor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Dijual oleh", style: TextStyle(fontSize: 8)),
                      Text("${sales[index].staff != null ? sales[index].staff!.name : "Pemilik"}", style: TextStyle(fontSize: 8, color: sales[index].staff != null ? blackColor : blueColor))
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
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 0),
            child: Text("Daftar Penjulan ($total)", style: const TextStyle(fontSize: 12)),
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
                  itemCount: loading ? 3 : loadmore ? sales.length + 1 : sales.isNotEmpty ? sales.length : 1,
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
                    suffix: () {
                      return TouchableOpacity(
                        onPress: viewFilter,
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: Icon(Boxicons.bx_filter, size: 22, color: filter.isNotEmpty ? redColor : const Color(0xFF767676))
                        )
                      );
                    }
                  )
                ),
                TouchableOpacity(
                  onPress: handlerCreateSales,
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