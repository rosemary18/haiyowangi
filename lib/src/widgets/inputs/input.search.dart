import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haiyowangi/src/index.dart';
import 'package:iconly/iconly.dart';

class InputSearch extends StatefulWidget {
  
  final EdgeInsets margin;
  final String placeholder;
  final String? errorText;
  final TextEditingController? controller;
  final TextStyle textStyle;
  final int? maxCharacter;
  final bool enabled;
  final bool obscure;
  final Widget? prefixIcon;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;

  const InputSearch({
    super.key,
    this.margin = const EdgeInsets.only(bottom: 0),
    this.placeholder = "Cari..",
    this.errorText,
    this.controller,
    this.textStyle = const TextStyle(color: Color.fromARGB(255, 47, 47, 47), fontSize: 14),
    this.maxCharacter,
    this.enabled = true,
    this.obscure = false,
    this.prefixIcon,
    this.onChanged,
    this.onSubmitted
  });

  @override
  State<InputSearch> createState() => _InputSearchState();
}

class _InputSearchState extends State<InputSearch> {

  String value = "";

  @override
  void initState() {
    super.initState();
    value = widget.controller?.text ?? "";
  }

  void handlerChange(String v) {
    setState(() {
      value = v;
    });
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: widget.margin,
      height: 38,
      child: TextField(
        controller: widget.controller,
        onChanged: handlerChange,
        onSubmitted: widget.onSubmitted,
        cursorColor: const Color.fromARGB(255, 55, 98, 218),
        enabled: widget.enabled,
        decoration: InputDecoration(
          prefixIcon: const Icon(IconlyLight.search, size: 14, color: Color(0xFF767676)),
          prefixIconConstraints: const BoxConstraints.expand(width: 38, height: 38),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          hintText: widget.placeholder,
          hintStyle: const TextStyle(color: greyTextColor),
          fillColor: greyColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(width: 0, style: BorderStyle.none),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(width: 0, style: BorderStyle.none),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: primaryColor, width: 1),
          ),
          filled: true,
          counterStyle: const TextStyle(fontSize: 0, height: 0),
          errorText: widget.errorText,
          errorStyle: const TextStyle(color: Colors.red, fontSize: 10),
          suffixIcon: value.isNotEmpty ? TouchableOpacity(
            onPress: () {
              widget.controller?.clear();
              handlerChange("");
            },
            child: const Icon(Icons.close, size: 14, color: Color(0xFF767676))
          ) : null,
        ),
        style: widget.textStyle,
        maxLength: widget.maxCharacter,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        textAlignVertical: TextAlignVertical.center,
      ),
    );
  }
}
