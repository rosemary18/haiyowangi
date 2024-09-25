import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:go_router/go_router.dart';
import 'package:haiyowangi/src/index.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class IngredientsView extends StatefulWidget {
  const IngredientsView({super.key});

  @override
  State<IngredientsView> createState() => _IngredientsViewState();
}

class _IngredientsViewState extends State<IngredientsView> {

  final _repository = IngredientRepository();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<IngredientModel> ingredients = [];
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
      ingredients.clear();
      for (var item in response.data!["data"]!["ingredients"]) {
        ingredients.add(IngredientModel.fromJson(item));
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
      for (var item in res.data!["data"]!["ingredients"]) {
        ingredients.add(IngredientModel.fromJson(item));
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

    if (!loading && !loadmore && ingredients.isEmpty)  {
      return const SizedBox(
        height: 40,
        child: Center(
          child: Text("Bahan tidak ditemukan!", style: TextStyle(color: greyTextColor, fontSize: 12)),
        ),
      );
    } 

    if (index == ingredients.length && loadmore)  {
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
        var result = await context.pushNamed(appRoutes.detailIngredient.name, extra: jsonEncode(ingredients[index]));
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              child: (ingredients[index].img!.isNotEmpty) ? Image.network("${ingredients[index].img}", height: 40, width: 40, fit: BoxFit.cover) : Center(
                child: Text(ingredients[index].name![0], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ingredients[index].name ?? "-", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  Text("${formatDouble(ingredients[index].qty ?? 0.0)} ${ingredients[index].uom?.name}", style: const TextStyle(fontSize: 8, color: greyTextColor)),
                  const SizedBox(height: 2),
                  const Text("Terakhir diubah", style: TextStyle(fontSize: 8, color: greyTextColor)),                  
                  Text(formatDateFromString("${ingredients[index].updatedAt}"), style: const TextStyle(fontSize: 8))                  
                ],
              ),
            ),
            if (ingredients[index].ingredients.isNotEmpty) Container(
              margin: const EdgeInsets.only(left: 6),
              child: const Icon(
                Boxicons.bx_link,
                color: blueColor,
                size: 14
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
            child: Text("Daftar Bahan ($total)", style: const TextStyle(fontSize: 12)),
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
                  itemCount: loading ? 3 : loadmore ? ingredients.length + 1 : ingredients.isNotEmpty ? ingredients.length : 1,
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
                    var result = await context.pushNamed(appRoutes.formIngredient.name);
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