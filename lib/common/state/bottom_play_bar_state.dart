import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomPlayBarState extends ChangeNotifier {

  bool _visible = true;

  BottomPlayBarState();

  bool get visible => _visible;

  void showBottomPlayBar() {
    _visible = true;
    notifyListeners();
  }

  void hideBottomPlayBar() {
    _visible = false;
    notifyListeners();
  }

  static BottomPlayBarState of(BuildContext context) {
    return Provider.of<BottomPlayBarState>(context);
  }

}