import 'package:flutter/material.dart';

class CustomSnackBar {
  static void show(BuildContext context, String message, bool error) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top +
            16.0, // Add some padding from the top
        left: 16.0, // Add some horizontal margin
        right: 16.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: error ?Colors.orange[100] : Colors.green[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  error ? Icons.info_outline : Icons.check_circle_outline,
                  color: error ?Colors.orange[800] : Colors.green[800],
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: error ?Colors.orange[800] : Colors.green[800],
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}
