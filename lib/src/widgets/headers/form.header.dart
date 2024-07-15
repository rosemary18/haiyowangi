import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';

class FormHeader extends StatelessWidget implements PreferredSizeWidget {

  final String title;

  const FormHeader({
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
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                TouchableOpacity(
                  onPress: () => rootNavigatorKey.currentState?.pop(),
                  child: const Icon(
                    Icons.close, 
                    color: Color.fromARGB(255, 74, 74, 74),
                    size: 20,
                  ),
                )
              ]
            ),
          )
        ],
        automaticallyImplyLeading: false,
      );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(40);
}