import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
class LoadingIndicator {
  final BuildContext context;

  LoadingIndicator(this.context);

  void showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false, // Kullanıcının dialogu kapatmasını engeller
      builder: (context) {
        return Center(
          child: LoadingAnimationWidget.flickr(
            leftDotColor: Color(0xFF023373),
            rightDotColor: Color(0xFF04C4D9),
            size: 80,
          ),
        );
      },
    );
  }
}
