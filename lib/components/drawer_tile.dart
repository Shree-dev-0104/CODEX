import 'package:flutter/material.dart';

class DrawerTile extends StatelessWidget {
  final String title;
  final Widget leadingIcon;
  final VoidCallback onTap;
  const DrawerTile({
    super.key,
    required this.title,
    required this.leadingIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 25,
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),),
        leading: leadingIcon,
        onTap: onTap,
      ),
    );
  }
}
