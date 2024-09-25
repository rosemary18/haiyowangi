import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';
import 'variants/index.dart';

class ProductView extends StatefulWidget {
  const ProductView({super.key});

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> with SingleTickerProviderStateMixin {

  late TabController _tabController;
  int tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      setState(() {
        tabIndex = _tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: primaryColor,
              unselectedLabelColor: greyTextColor,
              indicatorColor: primaryColor,
              dividerColor: greyColor,
              indicatorSize: TabBarIndicatorSize.label,
              overlayColor: WidgetStateProperty.all(primaryColor),
              automaticIndicatorColorAdjustment: true,
              tabs: const [
                Tab(
                  child: Text("Produk", style: TextStyle(fontFamily: FontMedium)),
                ),
                Tab(
                  child: Text("Varian", style: TextStyle(fontFamily: FontMedium)),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  ProductsView(),
                  VariantsView()
                ]
              )
            )
          ],
        ),
      )
    );
  }
}