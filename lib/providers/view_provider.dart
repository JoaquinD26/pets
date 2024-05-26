import 'package:flutter/material.dart';

class ViewProvider extends ChangeNotifier {
  bool _isVisible = true;

  bool get isVisible => _isVisible;

  void hideBottomNavBar() {
    _isVisible = false;
    notifyListeners();
  }

  void showBottomNavBar() {
    _isVisible = true;
    notifyListeners();
  }
}
