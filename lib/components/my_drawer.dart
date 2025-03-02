import 'package:flutter/material.dart';
import 'package:vs_code_app/components/drawer_tile.dart';
import 'package:vs_code_app/pages/settings_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // HEADER
           DrawerHeader(
            child: Image.asset("assets/vs_code_logo.png")
          ),
          // NOTE TILE
          DrawerTile(
            title: "F I L E S",
            leadingIcon: const Icon(Icons.home),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          // SETTINGS TILE
          DrawerTile(
            title: "S E T T I N G S",
            leadingIcon: const Icon(Icons.settings),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ));
            },
          ),
        ],
      ),
    );
  }
}
