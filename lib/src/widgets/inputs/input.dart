import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:intl/intl.dart';
import '../buttons/button_opacity.dart';
import 'package:iconly/iconly.dart';
import '../../cores/themes/styles/index.dart';

class Input extends StatefulWidget {
  
  final EdgeInsets margin;
  final String title;
  final String placeholder;
  final String? errorText;
  final TextEditingController? controller;
  final TextStyle textStyle;
  final int? maxCharacter;
  final bool enabled;
  final bool readOnly;
  final bool obscure;
  final Widget? prefixIcon;
  final Function(String)? onChanged;
  final int maxLines;
  final bool isCurrency;
  final String currency;
  final String initialValue;
  final Widget Function(BuildContext)? descBuilder;
  final bool multiplication;
  final List<String> suggestions;
  final FocusNode? focusNode;
  final Widget? suffixIcon;
  final double? width;
  final double? height;
  final void Function(String)? onSubmitted;

  const Input({
    super.key,
    this.title = "",
    this.margin = const EdgeInsets.only(bottom: 0),
    this.placeholder = "",
    this.errorText,
    this.controller,
    this.focusNode,
    this.textStyle = const TextStyle(color: Color.fromARGB(255, 47, 47, 47), fontSize: 14),
    this.maxCharacter,
    this.enabled = true,
    this.readOnly = false,
    this.obscure = false,
    this.prefixIcon,
    this.onChanged,
    this.maxLines = 1,
    this.isCurrency = false, 
    this.currency = "Rp ",
    this.initialValue = "",
    this.descBuilder,
    this.multiplication = false,
    this.suggestions = const [],
    this.suffixIcon,
    this.onSubmitted,
    this.width,
    this.height
  });

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {

  late bool obscureText = widget.obscure;
  late NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: widget.currency, decimalDigits: 0);
  late FocusNode focusNode = widget.focusNode ?? FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller?.text = (widget.controller!.text.isEmpty ? widget.initialValue : widget.controller?.text)!;
    if (widget.isCurrency) {
      widget.controller?.addListener(formatCurrency);
      if (widget.initialValue.isEmpty && widget.controller!.text.isEmpty) {
        widget.controller?.text = "0";
      } else if (widget.controller!.text.isNotEmpty) {
        formatCurrency();
      }
    }
    if (widget.multiplication && widget.initialValue.isEmpty && (widget.controller != null && widget.controller!.text.isEmpty)) {
      widget.controller?.text = "0";
    }
  }

  void formatCurrency() {
    String text = widget.controller!.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.isEmpty) {
      widget.controller?.value = const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
      return;
    }
    double value = double.parse(text);
    widget.controller?.value = TextEditingValue(
      text: currencyFormat.format(value),
      selection: TextSelection.collapsed(offset: currencyFormat.format(value).length),
    );
  }

  void handlerMultiplication({bool plus = true}) async {
    String text = widget.controller!.text;
    if (text.isEmpty) {
      widget.controller?.value = const TextEditingValue(
        text: '0',
        selection: TextSelection.collapsed(offset: 0),
      );
      return;
    }
    double parsed = double.parse(text);
    double value = plus ? parsed + 1 : max(parsed - 1, 0);
    widget.controller?.text = value.toString();
  }

  Widget buildIconObscure() {
    return TouchableOpacity(
    child: Icon(
      (obscureText) ? IconlyBold.hide : IconlyBold.show,
      color:(obscureText) ? const Color(0xFFDCDCDC) : primaryColor,
      size: 22,
    ),
    onPress: () {
      setState(() {
        obscureText = !obscureText;
      });
    });
  }

  Widget buidlMultiplicationInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TouchableOpacity(
            onPress: () => handlerMultiplication(plus: false),
            child: const Icon(
              Boxicons.bx_minus,
              color: greyDarkColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          TouchableOpacity(
            onPress: handlerMultiplication,
            child: const Icon(
              Boxicons.bx_plus,
              color: greyDarkColor,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(covariant Input oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCurrency == false && widget.isCurrency) {
      formatCurrency();
      widget.controller?.addListener(formatCurrency);
    } else if (oldWidget.isCurrency && widget.isCurrency == false) {
      widget.controller?.removeListener(formatCurrency);
      if (widget.multiplication) {
        var t = widget.controller!.text.split(".")[0].replaceAll(RegExp(r'[^\d]'), '');
        widget.controller?.text = t;
      }
    }
  }

  @override
  void dispose() {
    if (widget.isCurrency) widget.controller!.removeListener(formatCurrency);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: widget.margin,
      width: widget.width,
      height: widget.height,
      clipBehavior: Clip.none,
      decoration: const BoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title.isNotEmpty) Text(widget.title, style: const TextStyle(color: blackColor, fontSize: 12, fontFamily: FontMedium)),
          Container(
            clipBehavior: Clip.none,
            decoration: const BoxDecoration(),
            height: (!widget.obscure && widget.maxLines > 1) ? 80 : 50,
            margin: (widget.title.isNotEmpty) ? const EdgeInsets.only(top: 4) : EdgeInsets.zero,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty || widget.suggestions.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return widget.suggestions.where((String option) {
                      return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    widget.controller?.text = selection;
                  },
                  optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              clipBehavior: Clip.hardEdge,
                              width: constraints.maxWidth,
                              constraints: const BoxConstraints(maxHeight: 200),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.4),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  return TouchableOpacity(
                                    onPress: () => onSelected(option),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(option, style: const TextStyle(color: blackColor, fontSize: 14)),
                                    ), 
                                  );
                                },
                              )
                            )
                          ]
                        )
                      ],
                    );
                  },
                  fieldViewBuilder: (BuildContext context, TextEditingController controller, FocusNode fn, VoidCallback onFieldSubmitted) {

                    if (widget.suggestions.isNotEmpty) {
                      if (widget.controller!.text.isNotEmpty && widget.suggestions.isNotEmpty && focusNode.hasFocus) {
                        fn.requestFocus();
                      }
                      if (controller.text.isEmpty) {
                        controller.text = widget.controller!.text;
                      }
                      controller.addListener(() {
                        widget.controller!.text = controller.text;                        
                      });
                    }
                     
                    return TextField(
                      focusNode: widget.suggestions.isNotEmpty ? fn : focusNode,
                      controller: widget.suggestions.isNotEmpty ? controller : widget.controller,
                      onChanged: widget.onChanged,
                      cursorColor: const Color.fromARGB(255, 55, 98, 218),
                      enabled: widget.enabled,
                      readOnly: widget.readOnly,
                      decoration: InputDecoration(
                        prefixIcon: widget.prefixIcon,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        hintText: widget.placeholder,
                        hintStyle: const TextStyle(color: Color(0xFF767676)),
                        fillColor: const Color.fromARGB(59, 238, 238, 238),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: const BorderSide(color: greySoftColor, width: 1),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: const BorderSide(color: greySoftColor, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: const BorderSide(color: primaryColor, width: 1),
                        ),
                        filled: true,
                        counterStyle: const TextStyle(fontSize: 0, height: 0),
                        errorText: widget.errorText,
                        errorStyle: const TextStyle(color: Colors.red, fontSize: 10),
                        suffixIcon: widget.multiplication ? buidlMultiplicationInput() : widget.obscure ? buildIconObscure() : widget.suffixIcon
                      ),
                      maxLines: obscureText ? 1 : widget.maxLines,
                      style: widget.textStyle,
                      obscureText: obscureText,
                      maxLength: widget.maxCharacter,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      keyboardType: (widget.isCurrency || widget.multiplication) ? TextInputType.number : TextInputType.text,
                      onSubmitted: widget.onSubmitted,
                    );
                  },
                  optionsViewOpenDirection: OptionsViewOpenDirection.down,
                  optionsMaxHeight: 200,
                );
              }
            )
          ),
        
          if (widget.descBuilder != null) widget.descBuilder!(context)
        ],
      ),
    );
  }
}
