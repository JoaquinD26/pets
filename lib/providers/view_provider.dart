import 'package:flutter/material.dart';
//TODO puede sernos util en un futuro, ahora no hace nada.
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
