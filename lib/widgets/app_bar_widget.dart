import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton(icon: Icon(Icons.menu_rounded), onPressed: () {}),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none_rounded),
          onPressed: () {},
        ),
        IconButton(icon: Icon(Icons.person_outline_rounded), onPressed: () {}),
      ],
    );
  }
}
