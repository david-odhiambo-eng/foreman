import 'package:flutter/material.dart';
import 'package:foreman/views/home/textStyle.dart';

class AppTopBar extends StatefulWidget implements PreferredSizeWidget {
  const AppTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(120); // Increased slightly for better spacing

  @override
  State<AppTopBar> createState() => _AppTopBarState();
}

class _AppTopBarState extends State<AppTopBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Foreman', 
        style: reusableStyle2().copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 60,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabButton('Daily Summary'),
                const SizedBox(width: 12),
                _buildTabButton('Weekly Summary'),
                const SizedBox(width: 12),
                _buildTabButton('Monthly Summary'),
              ],
            ),
          ),
        ),
      ),
      leading: IconButton(
        onPressed: (){}, 
        icon: const Icon(Icons.menu, color: Colors.black87),
        iconSize: 28,
      ),
      actions: [
        IconButton(
          onPressed: (){}, 
          icon: const Icon(Icons.notifications, color: Colors.black87),
          iconSize: 28,
        ),
        const SizedBox(width: 8),
      ],
      backgroundColor: Colors.white,
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
      ),
    ));
  }

  Widget _buildTabButton(String text) {
    return OutlinedButton(
      onPressed: (){}, 
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blue.shade700,
        side: BorderSide(color: Colors.blue.shade700),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}