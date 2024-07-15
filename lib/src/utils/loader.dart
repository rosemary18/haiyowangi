import 'package:flutter/material.dart';
import 'package:haiyowangi/src/index.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

void showModalLoader({ Duration? duration }) async {

  rootNavigatorKey.currentState?.push(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: false,
      pageBuilder: (BuildContext context, _, __) {
        return PopScope(
          canPop: false,
          child: Dialog(
            insetPadding: const EdgeInsets.all(0),
            backgroundColor: const Color.fromARGB(107, 54, 54, 54),
            elevation: 0,
            child: Center(
              child: LoadingAnimationWidget.threeArchedCircle(size: 50, color: Colors.white),
            ),
          ),
        );
      },
    ),
  );

  if (duration != null) {
    await Future.delayed(duration);
    rootNavigatorKey.currentState?.pop();
  }

}