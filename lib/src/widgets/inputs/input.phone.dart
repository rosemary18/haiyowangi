import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class InputPhone extends StatefulWidget {

  final TextEditingController controller;
  final String placeholder;
  final String title;
  final EdgeInsets margin;

  const InputPhone({
    super.key, 
    required this.controller,
    this.placeholder = "Nomor Handphone",
    this.title = "",
    this.margin = const EdgeInsets.only(bottom: 8, top: 0),
  });

  @override
  State<InputPhone> createState() => _InputPhoneState();
}

class _InputPhoneState extends State<InputPhone> {

  PhoneNumber initialNumber = PhoneNumber(isoCode: 'ID');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title.isNotEmpty) Text(widget.title, style: const TextStyle(color: blackColor, fontSize: 14, fontFamily: FontMedium)),
          Container(
            height: 48,
            margin: (widget.title.isNotEmpty) ? const EdgeInsets.only(top: 4) : EdgeInsets.zero,
            child: InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) {},
              onInputValidated: (bool value) {},
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.DROPDOWN,
                setSelectorButtonAsPrefixIcon: true,
                useEmoji: true,
                trailingSpace: false,
                leadingPadding: 12
              ),
              ignoreBlank: false,
              countries: const ["ID"],
              autoValidateMode: AutovalidateMode.disabled,
              selectorTextStyle: const TextStyle(color: Color.fromARGB(255, 47, 47, 47), fontSize: 14),
              textFieldController: widget.controller,
              formatInput: true,
              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
              onSaved: (PhoneNumber number) {},
              inputDecoration: InputDecoration(
                hintText: widget.placeholder,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                fillColor: const Color(0xFFEEEEEE),
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: const BorderSide(width: 0, style: BorderStyle.none),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: const BorderSide(color: primaryColor, width: 1),
                ),
              ),
              initialValue: initialNumber,
              spaceBetweenSelectorAndTextField: 12,
              textStyle: const TextStyle(color: Color.fromARGB(255, 47, 47, 47), fontSize: 14),
              maxLength: 16,
            ),
          )
        ],
      )
    );
  }
}