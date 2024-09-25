import 'dart:developer';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';

class InputDropDown extends StatefulWidget {

  final String title;
  final String placeholder;
  final EdgeInsets margin;
  final List<String> list;
  final String? initialValue;
  final Function(String?)? onChanged;

  const InputDropDown({
    super.key,
    this.title = '',
    this.placeholder = '',
    this.margin = EdgeInsets.zero,
    this.list = const [],
    this.initialValue,
    this.onChanged
  });

  @override
  State<InputDropDown> createState() => _InputDropDownState();
}

class _InputDropDownState extends State<InputDropDown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title.isNotEmpty) Text(widget.title, style: const TextStyle(color: blackColor, fontSize: 12, fontFamily: FontMedium)),
          Container(
            margin: widget.title.isEmpty ? EdgeInsets.zero : const EdgeInsets.only(top: 4),
            child: CustomDropdown(
              hintText: widget.placeholder,
              items: widget.list,
              initialItem: widget.initialValue,
              listItemPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: CustomDropdownDecoration(
                closedFillColor: const Color.fromARGB(59, 238, 238, 238),
                closedBorderRadius: BorderRadius.circular(4),
                expandedBorderRadius: BorderRadius.circular(4),
                closedBorder: Border.all(color: greySoftColor, width: 1),
                headerStyle: const TextStyle(fontSize: 14, color: blackColor),
                hintStyle: const TextStyle(color: Color(0xFF767676)),
                listItemStyle: const TextStyle(fontSize: 14)
              ),
              itemsListPadding: const EdgeInsets.all(0),
              expandedHeaderPadding: const EdgeInsets.all(12),
              closedHeaderPadding: const EdgeInsets.all(12),
              onChanged: (widget.onChanged != null) ? widget.onChanged : (v) {
                log(v.toString());
              },
            ),
          )
        ],
      ),
    );
  }
}