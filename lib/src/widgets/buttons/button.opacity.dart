import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';

class ButtonOpacity extends StatelessWidget {

  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Widget? content;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeigth;
  final bool disabled;

  final void Function()? onPress;

  const ButtonOpacity({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    this.margin = EdgeInsets.zero,
    this.content,
    this.text = "Button",
    this.onPress,
    this.backgroundColor = const Color.fromARGB(255, 47, 47, 47),
    this.textColor = Colors.white,
    this.disabled = false,
    this.fontSize = 14,
    this.fontWeigth = FontWeight.bold
  });

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      onPress: disabled ? null : onPress,
      activeOpacity: disabled ? 1.0 : 0.7,
      child: Container(
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          color: disabled ? greyLightColor : backgroundColor,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: content ?? Center(
          child: Text(
            text, 
            style: TextStyle(
              color: disabled ? greyTextColor : textColor, 
              fontSize: fontSize,
              fontWeight: fontWeigth
            )
          ),
        ),
      ), 
    );
  }
}