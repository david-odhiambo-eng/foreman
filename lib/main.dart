import 'package:flutter/material.dart';
import 'package:foreman/models/worker_provider.dart';
import 'package:foreman/viewModel/group_adapter.dart';
import 'package:foreman/viewModel/worker_adapter.dart';
import 'package:foreman/views/home/home_page.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Clear existing data if needed (remove this in production)
  
  
  //hive for group name
  Hive.registerAdapter(GroupAdapter());
  await Hive.openBox<Group>('groups');

  //hive for worker name
  Hive.registerAdapter(WorkerAdapter());
  await Hive.openBox<Worker>('workers');
  
  runApp(Foreman());
}

class Foreman extends StatelessWidget {
  const Foreman({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WorkerProvider())
      ],
      child: MaterialApp(
        home: Home(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.white)),
      )
    );
  }
}