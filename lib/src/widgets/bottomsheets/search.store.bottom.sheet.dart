import 'dart:async';

import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';

class SearchStore extends StatefulWidget {

  final bool multiple;
  final bool showIngredient;
  final bool showPacket;

  const SearchStore({
    super.key,
    this.multiple = false,
    this.showIngredient = false,
    this.showPacket = false
  });

  @override
  State<SearchStore> createState() => _SearchStoreState();
}

class _SearchStoreState extends State<SearchStore> {

  final repository = StoreRepository();

  List<StoreModel> stores = [];


  bool loading = true;
  Timer? timeId;

  @override
  void initState() {
    super.initState();
    handlerGetData();
  }

  void handlerGetData() async {

    final response = await repository.getAllStores();
    
    if (response.statusCode == 200) {
      stores.clear();
      for (var item in response.data!["data"]) {
        stores.add(StoreModel.fromJson(item));
      }
    }

    loading = false;
    setState(() {});
  }

  void handlerSelectStore(StoreModel store) {

    Navigator.pop(context, store);
  }

  // Views


  Widget buildCard(StoreModel store) {
    return TouchableOpacity(
      onPress: () => handlerSelectStore(store),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(4),
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: greyLightColor, width: 0.5),
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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
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
                    child: (store.storeImage!.isNotEmpty) ? Image.network("${store.storeImage}", height: 40, width: 40, fit: BoxFit.cover) 
                      : Center(child: Text(store.name![0], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)))
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(store.name!, style: const TextStyle(fontSize: 14, fontFamily: FontMedium)),
                      Text(store.address!.isEmpty ? "-" : store.address!, style: const TextStyle(fontSize: 10, color: greyTextColor))
                    ],
                  ),
                ],
              )
            ),
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          boxShadow: [
            BoxShadow(color: Color.fromARGB(22, 0, 0, 0), blurRadius: 10, spreadRadius: 2.5)
          ]
        ),
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              height: double.infinity,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    width: double.infinity,
                    child: Center(
                      child: Container(
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: greyLightColor,
                          borderRadius: BorderRadius.circular(4)
                        ),
                      )
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12), 
                    child: Text("Semua Toko", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: stores.length,
                    padding: EdgeInsets.only(top: 12, bottom: 12+MediaQuery.of(context).padding.bottom),
                    itemBuilder: (context, index) => buildCard(stores[index]),
                  ),
                ]
              ),              
            ),
          ],
        )
      ),
    );
  }
}