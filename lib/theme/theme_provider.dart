import 'package:flutter/material.dart';
import 'package:vs_code_app/theme/theme.dart';
// Importing the theme configuration file where `lightMode` and `darkMode` ThemeData are defined.

/// The `ThemeProvider` class is a `ChangeNotifier` that provides state management for switching between light and dark themes.
class ThemeProvider extends ChangeNotifier {
  // Initial theme is set to light mode.
  ThemeData _themeData = lightMode;

  // Getter method to retrieve the current theme.
  // This allows other parts of the app to access the active ThemeData.
  ThemeData get themeData => _themeData;

  // Getter method to check if the current theme is dark mode.
  // Returns `true` if the current theme is `darkMode`, otherwise `false`.
  bool get isDarkMode => _themeData == darkMode;

  // Setter method to update the theme.
  // When a new theme is set, `notifyListeners()` informs all listeners
  // (e.g., widgets using `Provider`) that the theme has changed.
  set themeData(ThemeData themeData) {
    _themeData = themeData; // Update the private `_themeData` field.
    notifyListeners(); // Notify all listeners about the theme change.
  }

  // Function to toggle between light and dark themes.
  // If the current theme is `lightMode`, switch to `darkMode`.
  // Otherwise, switch back to `lightMode`.
  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode; // Switch to dark mode.
    } else {
      themeData = lightMode; // Switch to light mode.
    }
  }
}
