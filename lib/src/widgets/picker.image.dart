import 'dart:io';

import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';
import 'package:image_picker/image_picker.dart';

class PickerImage extends StatefulWidget {

  final File? img;
  final Function(File?)? onSelected;

  const PickerImage({
    super.key,
    this.img,
    this.onSelected
  });

  @override
  State<PickerImage> createState() => _PickerImageState();
}

class _PickerImageState extends State<PickerImage> {

  File? img;

  @override
  void initState() {
    super.initState();
    img = widget.img;
  }

  void _pickImage() async {

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        img = File(pickedFile.path);
        widget.onSelected?.call(img);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      onPress: _pickImage,
      child: Container(
        height: 56,
        width: 56,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: white1Color,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: (img == null) ? Image.asset(appImages["IMG_DEFAULT"]!, fit: BoxFit.fill) : Image.file(img!, fit: BoxFit.fill),
      ), 
    );
  }
}