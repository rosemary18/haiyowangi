import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';

class DetailHeader extends StatelessWidget implements PreferredSizeWidget {

  final String title;

  const DetailHeader({
    super.key,
    this.title = 'Title',
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: const Color.fromARGB(255, 247, 247, 247),
        title: Text(
          title, 
          style: const TextStyle(color: Color.fromARGB(255, 74, 74, 74), fontWeight: FontWeight.bold, fontSize: 16)
        ),
        shadowColor: Colors.black,
        centerTitle: false,
        elevation: .5,
        leading: Container(
          margin: const EdgeInsets.only(bottom: 6, left: 4),
          child: TouchableOpacity(
            onPress: () => rootNavigatorKey.currentState?.pop(),
            child: const Icon(
              CupertinoIcons.arrow_left, 
              color: Color.fromARGB(255, 74, 74, 74),
              size: 20,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        titleSpacing: 4,
        leadingWidth: 40,
      );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(40);
}