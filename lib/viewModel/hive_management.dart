import 'package:foreman/viewModel/worker_adapter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(WorkerModelAdapter());
    Hive.registerAdapter(GroupModelAdapter());
    
    await _openBoxes();
  }

  static Future<void> _openBoxes() async {
    try {
      if (!Hive.isBoxOpen('workers')) {
        await Hive.openBox<WorkerModel>('workers');
      }
      if (!Hive.isBoxOpen('groups')) {
        await Hive.openBox<GroupModel>('groups');
      }
    } catch (e) {
      // If error occurs, delete boxes and retry
      await Hive.deleteBoxFromDisk('workers');
      await Hive.deleteBoxFromDisk('groups');
      await _openBoxes();
    }
  }

  static Future<void> closeBoxes() async {
    await Hive.close();
  }
}