import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vs_code_app/theme/theme_provider.dart';

/// The `SettingsPage` widget allows users to toggle between light and dark modes in the app.
/// It is a stateless widget because all its state is managed by the `ThemeProvider` using the Provider pattern.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set the background color of the screen based on the current theme.
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0, // Removes the shadow under the AppBar.
        backgroundColor: Colors.transparent, // Transparent AppBar background.
        foregroundColor: Theme.of(context)
            .colorScheme
            .inversePrimary, // Icon and text color.
      ),
      body: Container(
        // Padding and margin for spacing around the container.
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 25,
        ),
        margin: const EdgeInsets.only(
          left: 25,
          right: 25,
          top: 10,
        ),
        // Rounded corners and background color for the container.
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.primary, // Background color.
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Space out elements in the row.
          children: [
            // Text label for the toggle switch.
            Text(
              "Dark Mode", // Label for the dark mode toggle.
              style: TextStyle(
                fontWeight: FontWeight.bold, // Bold text.
                color:
                    Theme.of(context).colorScheme.inversePrimary, // Text color.
              ),
            ),
            // CupertinoSwitch is used as a toggle for switching themes.
            CupertinoSwitch(
              value: Provider.of<ThemeProvider>(context, listen: false)
                  .isDarkMode, // Gets the current theme mode from the ThemeProvider.
              onChanged: (value) => Provider.of<ThemeProvider>(context,
                      listen: false)
                  .toggleTheme(), // Toggles the theme when the switch is toggled.
            ),
          ],
        ),
      ),
    );
  }
}
