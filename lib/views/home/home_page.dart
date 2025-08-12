import 'package:flutter/material.dart';
import 'package:foreman/views/home/app_bar.dart';
import 'package:foreman/views/home/body_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(),
      body: BodyPage(),
    );
  }
}