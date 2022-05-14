import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class CommonLoading {

  static showLoading() {
    _configLoading();
    EasyLoading.show();
  }

  static hideLoading() {
    EasyLoading.dismiss();
  }
  
  static void _configLoading() {
    EasyLoading.instance
      ..maskType = EasyLoadingMaskType.custom
      ..maskColor = Colors.transparent
      ..backgroundColor = Colors.transparent
      ..dismissOnTap = false;
  }
}