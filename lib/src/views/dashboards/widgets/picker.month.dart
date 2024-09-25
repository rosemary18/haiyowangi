import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';

class PickerMonth extends StatefulWidget {

  final EdgeInsets margin;
  final DateTime? value;
  final Function(DateTime)? onChange;

  const PickerMonth({
    super.key,
    this.margin = EdgeInsets.zero,
    this.value,
    this.onChange
  });

  @override
  State<PickerMonth> createState() => _PickerMonthState();
}

class _PickerMonthState extends State<PickerMonth> {

  DateTime value = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      value = widget.value!;
    }
  }

  @override
  void didUpdateWidget(covariant PickerMonth oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null && widget.value != value) {
      value = widget.value!;
    }
  }

  void handlerChangeMonth({bool next = true}) {
    if (next) {
      value = DateTime(value.year, value.month + 1);
    } else {
      value = DateTime(value.year, value.month - 1);
    }
    widget.onChange?.call(value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: Row(
        children: [
          TouchableOpacity(
            onPress: () => handlerChangeMonth(next: false),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(0, 1), // changes position of shadow
                  ),
                ]
              ),
              child: const Icon(
                Icons.chevron_left,
                size: 24,
                color: primaryColor
              ),
            )
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
              ),
              child: Center(
                child: Text(
                  formatDateFromString(value.toString(), format: "MMMM yyyy"), 
                  style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600), 
                  textAlign: TextAlign.center
                ),
              ),
            )
          ),
          if (!(value.month == DateTime.now().month && value.year == DateTime.now().year)) const SizedBox(width: 8),
          if (!(value.month == DateTime.now().month && value.year == DateTime.now().year)) TouchableOpacity(
            onPress: handlerChangeMonth,
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(0, 1), // changes position of shadow
                  ),
                ]
              ),
              child: const Icon(
                Icons.chevron_right,
                size: 24,
                color: primaryColor
              ),
            )
          ),
        ],
      ),
    );
  }
}