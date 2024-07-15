import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../buttons/button_opacity.dart';
import 'package:iconly/iconly.dart';
import '../../cores/themes/styles/index.dart';

class Input extends StatefulWidget {
  
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
  final int maxLines;

  const Input({
    super.key,
    this.margin = const EdgeInsets.only(bottom: 0),
    this.placeholder = "Placeholder",
    this.errorText,
    this.controller,
    this.textStyle = const TextStyle(color: Color.fromARGB(255, 47, 47, 47), fontSize: 14),
    this.maxCharacter,
    this.enabled = true,
    this.obscure = false,
    this.prefixIcon,
    this.onChanged,
    this.maxLines = 1
  });

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  late bool obscureText = widget.obscure;

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

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: widget.margin,
      height:(!widget.obscure && widget.maxLines > 1) ? 80 : 54,
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        cursorColor: const Color.fromARGB(255, 55, 98, 218),
        enabled: widget.enabled,
        decoration: InputDecoration(
          prefixIcon: widget.prefixIcon,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          hintText: widget.placeholder,
          hintStyle: const TextStyle(color: Color(0xFF767676)),
          fillColor: const Color(0xFFEEEEEE),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: const BorderSide(width: 0, style: BorderStyle.none),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: const BorderSide(width: 0, style: BorderStyle.none),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: const BorderSide(color: primaryColor, width: 1),
          ),
          filled: true,
          counterStyle: const TextStyle(fontSize: 0, height: 0),
          errorText: widget.errorText,
          errorStyle: const TextStyle(color: Colors.red, fontSize: 10),
          suffixIcon: widget.obscure ? buildIconObscure() : null
        ),
        maxLines: obscureText ? 1 : widget.maxLines,
        style: widget.textStyle,
        obscureText: obscureText,
        maxLength: widget.maxCharacter,
        maxLengthEnforcement: MaxLengthEnforcement.enforced
      ),
    );
  }
}
