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
  final Widget Function()? suffix;
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
    this.suffix,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          hintText: widget.placeholder,
          hintStyle: const TextStyle(color: greyTextColor),
          fillColor: const Color.fromARGB(59, 238, 238, 238),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: greySoftColor, width: 1),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: greySoftColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: primaryColor, width: 1),
          ),
          filled: true,
          counterStyle: const TextStyle(fontSize: 0, height: 0),
          errorText: widget.errorText,
          errorStyle: const TextStyle(color: Colors.red, fontSize: 10),
          suffix: (value.isNotEmpty) ? TouchableOpacity(
            onPress: () {
              widget.controller?.clear();
              handlerChange("");
            },
            child: const SizedBox(
              height: 40,
              width: 26,
              child: Icon(Icons.close, size: 14, color: Color(0xFF767676))
            )
          ) : null,
          suffixIcon: widget.suffix == null ? null : widget.suffix!()
        ),
        style: widget.textStyle,
        maxLength: widget.maxCharacter,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        textAlignVertical: TextAlignVertical.center,
      ),
    );
  }
}
