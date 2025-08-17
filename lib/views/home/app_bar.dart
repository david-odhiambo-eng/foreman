import 'package:flutter/material.dart';
import 'package:foreman/views/home/textStyle.dart';

class AppTopBar extends StatefulWidget implements PreferredSizeWidget {
  const AppTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  State<AppTopBar> createState() => _AppTopBarState();
}

class _AppTopBarState extends State<AppTopBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'Foreman',
        style: reusableStyle2().copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.black87,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 6,
      shadowColor: Colors.black26,
      actions: [
        // Notification icon inside a circular background
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_outlined),
              color: Colors.blue.shade700,
              iconSize: 26,
            ),
          ),
        ),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
    );
  }
}
