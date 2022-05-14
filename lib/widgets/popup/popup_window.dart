import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PopupWindow extends StatelessWidget {

  final double width;
  final Widget contentWidget;

  PopupWindow({
    required this.width,
    required this.contentWidget,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: Center(
          child: contentWidget,
        ),
      ),
    );
  }
}
