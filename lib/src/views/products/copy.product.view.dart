import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haiyowangi/src/index.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CopyProductView extends StatefulWidget {
  const CopyProductView({super.key});

  @override
  State<CopyProductView> createState() => _CopyProductViewState();
}

class _CopyProductViewState extends State<CopyProductView> {

  final _repository = ProductRepository();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<ProductModel> products = [];
  int total = 0;
  int page = 1;
  int lastPage = 1;
  bool loading = true;
  bool loadmore = false;
  Timer? timeId;

  Map<String, dynamic> filter = {};
  StoreModel? activeStore;
  List<ProductModel> selectedItems = [];

  @override
  void initState() {
    super.initState();
    activeStore = context.read<AuthBloc>().state.store;
    handlerGetData();
  }

  @override
  void dispose() {
    timeId?.cancel();
    super.dispose();
  }

  // Handlers

  Future<void> handlerGetData() async {
    
    final response = await _repository.getData(
      "${activeStore!.id}", 
      queryParams: {
        "search_text": _searchController.text,
        ...filter
      }
    );

    total = 0;
    
    if (response.statusCode == 200) {
      products.clear();
      for (var item in response.data!["data"]!["products"]) {
        products.add(ProductModel.fromJson(item));
      }
      total = response.data!["data"]!["total"] ?? 0;
      page = response.data!["data"]!["current_page"];
      lastPage = response.data!["data"]!["total_page"];
    }

    loading = false;
    selectedItems.clear();
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
      for (var item in res.data!["data"]!["products"]) {
        products.add(ProductModel.fromJson(item));
      }
      page = res.data!["data"]!["current_page"];
      lastPage = res.data!["data"]!["total_page"];
      loadmore = false;
      setState(() {});
    }
  }

  void handlerSelectProduct(ProductModel item) {
    
    if (selectedItems.contains(item)) {
      selectedItems.remove(item);
    } else {
      selectedItems.add(item);
    }
    setState(() {});
  }

  Future<void> handlerCopyProduct() async {

    final state = context.read<AuthBloc>().state;
    final items = [];

    for (var item in selectedItems) {
      items.add(item.id);
    }

    final data = {
      "items": items
    };

    final response = await _repository.copyProductFromStore("${state.store!.id}", data);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Produk berhasil di salin!"),
          backgroundColor: Colors.green
        )
      );
      selectedItems.clear();
      setState(() {});
    }
  }

  // Views

  void handlerSelectStore() async {

    var x = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: Colors.transparent,
      clipBehavior: Clip.none,
      isScrollControlled: false,
      scrollControlDisabledMaxHeightRatio: .85,
      builder: (context) => const SearchStore(),
    );

    if (x != null) {
      setState(() {
        loading = true;
        activeStore = x;
        products.clear();
        handlerGetData();
      });
    }
  }


  Widget viewCard(BuildContext context, int index) {

    if (!loading && !loadmore && products.isEmpty)  {
      return const SizedBox(
        height: 40,
        child: Center(
          child: Text("Produk tidak ditemukan!", style: TextStyle(color: greyTextColor, fontSize: 12)),
        ),
      );
    } 

    if (index == products.length && loadmore)  {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LoadingAnimationWidget.threeArchedCircle(size: 24, color: primaryColor),
        ),
      );
    }

    if (loading) return const SkletonView(margin: EdgeInsets.only(bottom: 10), height: 60,);

    bool selected = selectedItems.contains(products[index]);

    return TouchableOpacity(
      onPress: () => handlerSelectProduct(products[index]),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? greenLightColor : Colors.white,
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
                Container(
                  height: 40,
                  width: 40,
                  margin: const EdgeInsets.only(right: 8),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: white1Color
                  ),
                  child: (products[index].img!.isNotEmpty) ? Image.network("${products[index].img}", height: 40, width: 40, fit: BoxFit.cover) : Center(
                    child: Text(products[index].name[0], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        products[index].name.isNotEmpty ? products[index].name : "-", 
                        style: const TextStyle(
                          fontSize: 14, 
                          fontWeight: FontWeight.w600
                        ),
                        maxLines: 2, 
                        overflow: TextOverflow.ellipsis
                      ),
                      Text("${formatDouble(products[index].qty ?? 0.0)} ${products[index].uom?.name}", style: const TextStyle(fontSize: 8, color: greyTextColor)),
                      if (products[index].hasVariants!) Text("${products[index].variants.length} Varian", style: const TextStyle(fontSize: 8, color: blueColor)),
                    ],
                  )
                ),
              ],
            )
          ],
        ),
      ), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FormHeader(title: "Salin Produk",),
      backgroundColor: white1Color,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Toko", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                TouchableOpacity(
                  onPress: handlerSelectStore,
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: EdgeInsets.all(activeStore != null ? 6 : 12),
                    constraints: const BoxConstraints(minHeight: 40),
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
                    child: activeStore == null ? const Row(
                      children: [
                        Text("Pilih Toko", style: TextStyle(fontSize: 12, color: greyTextColor))
                      ],
                    ) : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          margin: const EdgeInsets.only(right: 8),
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: white1Color
                          ),
                          child: (activeStore!.storeImage!.isNotEmpty) ? Image.network("${activeStore!.storeImage}", height: 40, width: 40, fit: BoxFit.cover) 
                            : Center(child: Text(activeStore!.name![0], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)))
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(activeStore!.name!, style: const TextStyle(fontSize: 14, fontFamily: FontMedium)),
                            Text(activeStore!.address!.isEmpty ? "-" : activeStore!.address!, style: const TextStyle(fontSize: 10, color: greyTextColor))
                          ],
                        ),
                      ],
                    ),
                  ), 
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: InputSearch(
              controller: _searchController,
              onChanged: handlerSearch
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 12, right: 12, bottom: 0),
            child: Text("Produk Toko ($total)", style: const TextStyle(fontSize: 12)),
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
                  itemCount: loading ? 3 : loadmore ? products.length + 1 : products.isNotEmpty ? products.length : 1,
                  itemBuilder: viewCard,
                  padding: const EdgeInsets.all(12),
                  physics: const AlwaysScrollableScrollPhysics(),
                ), 
              ),
            )
          ),
          ButtonOpacity(
            onPress: handlerCopyProduct,
            disabled: selectedItems.isEmpty,
            margin: const EdgeInsets.all(12),
            text: "Salin ${selectedItems.length}/12 produk",
            backgroundColor: primaryColor,
          )
        ],
      ),
    );
  }
}