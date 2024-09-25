import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:haiyowangi/src/index.dart';

class ManageVariantView extends StatefulWidget {

  final String data;

  const ManageVariantView({
    super.key,
    required this.data
  });

  @override
  State<ManageVariantView> createState() => _ManageVariantViewState();
}

class _ManageVariantViewState extends State<ManageVariantView> {

  final respository = VariantRepository();

  late ProductModel _product;
  List<VariantTypeModel> _types = [VariantTypeModel()];

  Timer? _timerId;

  @override
  void initState() {
    super.initState();
    _product = ProductModel.fromJson(jsonDecode(widget.data));
    if (_product.variant_types.isNotEmpty) {
      _types = _product.variant_types;
      setState(() {});
    }
    handlerGetTypes();
  }

  void handlerGetTypes() async {
    
    Response response = await respository.getVariantTypes("${_product.id}");
    if (response.statusCode == 200) {
      if ((response.data["data"] as List).isNotEmpty) {
        _types = (response.data["data"] as List).map((e) => VariantTypeModel.fromJson(e)).toList();
        setState(() {});        
      }
    }
  }

  void handlerAddVariantType() {

    VariantTypeModel lastVariantType = _types[_types.length - 1];

    if (lastVariantType.variants.isEmpty || lastVariantType.name!.isEmpty) {
      scaffoldMessengerKey.currentState!.showSnackBar(
        const SnackBar(
          content: Text("Tipe varian terakhir harus memiliki minimal 1 varian dan nama tipe varian harus diisi."),
          backgroundColor: redColor,
        ),
      );
      return;
    }

    _types.add(VariantTypeModel());
    setState(() {});
  }

  void handlerDeleteVariantType(int index) async {

    VariantTypeModel variantType = _types[index];

    if (variantType.id != null) {
      Response response = await respository.deleteVariantType("${variantType.id!}");
      if (response.statusCode == 200) {
        handlerGetTypes();
      }
    }

    _types.removeAt(index);
    setState(() {});
  }

  void handlerDeleteVariantTypeItem(int index, VariantTypeItemModel variantTypeItem) async {
    
    if (variantTypeItem.id != null) {

      Response response = await respository.deleteVariantTypeItem("${variantTypeItem.id!}");
      if (response.statusCode == 200) {
        handlerGetTypes();
      }
    }

    _types[index].variants.remove(variantTypeItem);
    setState(() {});
  }

  void handlerChangeType(VariantTypeModel variantType, {VariantTypeItemModel? variantTypeItem}) async {

    if (_timerId != null) {
      _timerId!.cancel();
    }

    if (variantTypeItem == null) {
      _timerId = Timer(const Duration(milliseconds: 500), () async {

        int? index;
        for (int i = 0; i < _types.length; i++) {
          if (_types[i].id == variantType.id) {
            index = i;
          }
        }

        if (index != null) {

          if (variantType.name!.isNotEmpty) {
            if (_types[index].id != null) {
              // Update
              final data = { "name": variantType.name };
              Response response = await respository.updateVariantType("${_types[index].id}", data);
              if (response.statusCode == 200) {
                handlerGetTypes();
              }
            } else {
              // Create new
              final data = { 
                "product_id": _product.id,
                "name": variantType.name 
              };
              Response response = await respository.addVariantType(data);
              if (response.statusCode == 200) {
                handlerGetTypes();
              }
            }
          }

          _types[index] = variantType;
          setState(() {});
        }
      });
      
    } else {

      final data = { 
        "variant_type_id": variantType.id,
        "name": variantTypeItem.name 
      };
      Response result = await respository.addVariantTypeItem(data);
      if (result.statusCode == 200) {
        handlerGetTypes();
      }

      setState(() {});
    }
    
  }

  Widget buildVariantType(BuildContext context, int index) {

    if (index == _types.length) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            const Divider(color: greyColor, height: 1),
            const SizedBox(height: 12),
            ButtonOpacity(
              onPress: handlerAddVariantType,
              text: "Tambah Tipe Varian",
              backgroundColor: primaryColor,
            )
          ],
        ),
      );
    }

    VariantTypeModel? variantType = _types[index];

    return FieldInputVariantType(
      index: index, 
      variantType: variantType, 
      variantTypes: _types, 
      onChange: handlerChangeType,
      onDeleteTypeItem: handlerDeleteVariantTypeItem,
      onDelete: handlerDeleteVariantType
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FormHeader(
        title: "Kelola Varian - ${_product.name}",
      ),
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, left: 12, right: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.38,
                    child: const Text("Tipe", style: TextStyle(color: blackColor, fontSize: 16, fontFamily: FontBold)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text("Varian", style: TextStyle(color: blackColor, fontSize: 16, fontFamily: FontBold)),
                  ),
                ]
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 8),
              child: const Divider(color: greyColor, height: 1),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 12),
                child: SingleChildScrollView(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _types.length + 1,
                    itemBuilder: buildVariantType,
                  ),
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}

class FieldInputVariantType extends StatefulWidget {

  final int index;
  final VariantTypeModel variantType;
  final List<VariantTypeModel> variantTypes;
  final void Function(VariantTypeModel, {VariantTypeItemModel? variantTypeItem}) onChange;
  final void Function(int, VariantTypeItemModel) onDeleteTypeItem;
  final void Function(int) onDelete;

  const FieldInputVariantType({
    super.key,
    required this.index,
    required this.variantType,
    required this.variantTypes,
    required this.onChange,
    required this.onDelete,
    required this.onDeleteTypeItem
  });

  @override
  State<FieldInputVariantType> createState() => _FieldInputVariantTypeState();
}

class _FieldInputVariantTypeState extends State<FieldInputVariantType> {

  final typeNameController = TextEditingController();
  final variantNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    typeNameController.text = widget.variantType.name!;
    typeNameController.addListener(() {
      widget.variantType.name = typeNameController.text;
      widget.onChange(widget.variantType);
    });
  }

  void handlerAddVariantTypeItem(v) {

    if (widget.variantType.name!.isEmpty) {
      scaffoldMessengerKey.currentState!.showSnackBar(
        const SnackBar(
          content: Text("Tipe varian harus diisi."),
          backgroundColor: redColor,
        ),
      );
      variantNameController.clear();
      return;
    }

    final nameList = widget.variantType.variants.map((item) => item.name).toList();
    nameList.add(variantNameController.text);
    if (nameList.length != nameList.toSet().length) {
      scaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(
          content: Text("Varian pada tipe varian \"${widget.variantType.name}\" tidak boleh ada yang sama."),
          backgroundColor: redColor,
        ),
      );
      variantNameController.clear();
      return;
    }

    final variantTypeItem = VariantTypeItemModel(name: variantNameController.text);
    if (widget.variantType.variants.isNotEmpty) {
      widget.variantType.variants.add(variantTypeItem);
    } else {
      widget.variantType.variants = [variantTypeItem];
    }

    widget.onChange(widget.variantType, variantTypeItem: variantTypeItem);
    variantNameController.clear();
  }

  Widget buildVariantItem(VariantTypeItemModel variantTypeItem) {

    int? index = widget.variantType.variants.indexWhere((e) => e.name == variantTypeItem.name);
    
    return Container(
      margin: const EdgeInsets.only(right: 8, top: 8),
      padding: const EdgeInsets.only(left: 8, right: 2, top: 2, bottom: 2),
      decoration: BoxDecoration(
        color: greySoftColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(variantTypeItem.name!, style: const TextStyle(color: blackColor, fontSize: 10)),
          const SizedBox(width: 6),
          TouchableOpacity(
            onPress: () => (index != 0 || widget.variantType.variants.length > 1) ? widget.onDeleteTypeItem(widget.index, variantTypeItem) : null,
            child: Icon(
              Boxicons.bx_x_circle, 
              color: (index != 0 || widget.variantType.variants.length > 1) ? redColor : greyColor, 
              size: 20
            ), 
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.38,
            child: Column(
              children: [
                Input(
                  controller: typeNameController,
                  placeholder: "Tipe varian",
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Input(
                  controller: variantNameController,
                  placeholder: "Varian",
                  onSubmitted: handlerAddVariantTypeItem,
                  descBuilder: (c) => Text("Tambah varian dari tipe ${widget.variantType.name!.isNotEmpty ? "\"${widget.variantType.name}\"" : "ini"}. Akhiri dengan enter.", style: const TextStyle(color: greyTextColor, fontSize: 8, fontFamily: FontRegular)),
                ),
                Wrap(
                  children: [
                    ...widget.variantType.variants.map(buildVariantItem)
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          if (!(widget.index == 0 && widget.variantType.id == null)) const SizedBox(width: 10),
          if (!(widget.index == 0 && widget.variantType.id == null)) TouchableOpacity(
            onPress: () => widget.onDelete(widget.index),
            child: const Icon(
              Boxicons.bxs_trash, 
              size: 18, 
              color: redColor
            )
          )
        ]
      ),
    );
  }
}