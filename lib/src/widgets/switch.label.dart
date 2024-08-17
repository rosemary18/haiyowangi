import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';

class SwitchLabel extends StatelessWidget {

  final String title;
  final String desc;
  final bool value;
  final Function(bool) onChanged;
  final EdgeInsets margin;

  const SwitchLabel({
    super.key,
    this.title = "",
    this.desc = "",
    this.margin = EdgeInsets.zero,
    required this.value,
    required this.onChanged
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: margin,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  if (desc.isNotEmpty) Text(desc, style: const TextStyle(fontSize: 10, color: greyTextColor)),
                ],
              )
            ),
            const SizedBox(width: 8),
            Switch(
              activeColor: white1Color,
              activeTrackColor: primaryColor,
              inactiveThumbColor: greyDarkColor,
              inactiveTrackColor: white1Color,
              trackOutlineWidth: WidgetStateProperty.all(0),
              value: value, 
              onChanged: onChanged
            )
          ]
        ),
      );
  }
}