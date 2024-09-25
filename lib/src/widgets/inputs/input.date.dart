import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:haiyowangi/src/index.dart';

class InputDate extends StatefulWidget {
  
  final bool range;
  final EdgeInsets margin;
  final String title;
  final String placeholder;
  final TextEditingController? controller;
  final TextStyle textStyle;
  final bool enabled;
  final Widget? prefixIcon;
  final Function(String)? onChanged;
  final String initialValue;
  final Widget Function()? descBuilder;

  const InputDate({
    super.key,
    this.range = false,
    this.title = "",
    this.margin = const EdgeInsets.only(bottom: 0),
    this.placeholder = "",
    this.controller,
    this.textStyle = const TextStyle(color: Color.fromARGB(255, 47, 47, 47), fontSize: 14),
    this.enabled = true,
    this.prefixIcon,
    this.onChanged,
    this.initialValue = "",
    this.descBuilder,
  });

  @override
  State<InputDate> createState() => _InputDateState();
}

class _InputDateState extends State<InputDate> {

  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller?.text = (widget.controller!.text.isNotEmpty ? formatDateFromString(widget.controller!.text, format: "yyyy/MM/dd") : widget.initialValue.isEmpty ? formatDateFromString(DateTime.now().toLocal().toString(), format: "yyyy/MM/dd") : widget.initialValue);
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        handlerPickDate();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handlerPickDate() async {
    if (widget.range) {
      DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        initialDateRange: DateTimeRange(start: DateTime.now(), end: DateTime.now()),
        initialEntryMode: DatePickerEntryMode.input,
        helpText: "Pilih Tanggal",
      );
      if (picked != null) {
        setState(() {
          if (picked.start.isAtSameMomentAs(picked.end)) {
            widget.controller?.text = formatDateFromString(picked.start.toString(), format: "yyyy/MM/dd");
          } else {
            widget.controller?.text = "${formatDateFromString(picked.start.toString(), format: "yyyy/MM/dd")} - ${formatDateFromString(picked.end.toString(), format: "yyyy/MM/dd")}";
          }
        });
      }
    } else {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: widget.controller!.text.isNotEmpty ? DateTime.parse(widget.controller!.text.replaceAll("/", "-")) : DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        initialDatePickerMode: DatePickerMode.day,
      );
      if (picked != null) {
        setState(() {
          widget.controller?.text = formatDateFromString(picked.toString(), format: "yyyy/MM/dd");
        });
      }
    }
    focusNode.unfocus();
    widget.onChanged?.call(widget.controller!.text);
  }

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
            height: 54,
            margin: (widget.title.isNotEmpty) ? const EdgeInsets.only(top: 4) : EdgeInsets.zero,
            child: TextField(
              focusNode: focusNode,
              controller: widget.controller,
              onChanged: widget.onChanged,
              cursorColor: const Color.fromARGB(255, 55, 98, 218),
              enabled: widget.enabled,
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
                suffixIcon: TouchableOpacity(
                  onPress: handlerPickDate,
                  child: const Icon(
                    Boxicons.bx_calendar,
                    color: greyDarkColor,
                    size: 22,
                  ),
                )
              ),
              style: widget.textStyle,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              readOnly: true,
            )
          ),
          if (widget.descBuilder != null) widget.descBuilder!()
        ],
      ),
    );
  }
}
