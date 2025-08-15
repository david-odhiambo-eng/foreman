import 'package:flutter/material.dart';
import 'package:foreman/viewModel/worker_adapter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';


class WorkerProvider with ChangeNotifier {
  late Box<GroupModel> _groupsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(WorkerModelAdapter());
    Hive.registerAdapter(GroupModelAdapter());
    _groupsBox = await Hive.openBox<GroupModel>('groups_box');
  }

  GroupModel? getGroup(String groupName) {
    return _groupsBox.get(groupName);
  }

  Future<void> addGroup(GroupModel group) async {
    await _groupsBox.put(group.groupName, group);
    notifyListeners();
  }

  Future<void> addWorker(String groupName, WorkerModel worker) async {
    final group = _groupsBox.get(groupName);
    if (group != null) {
      group.workers.add(worker);
      await group.save();
      notifyListeners();
    }
  }

  Future<void> updateWorker(String groupName, WorkerModel worker) async {
    await worker.save();
    notifyListeners();
  }

  Future<void> removeWorker(String groupName, WorkerModel worker) async {
    final group = _groupsBox.get(groupName);
    if (group != null) {
      group.workers.remove(worker);
      await group.save();
      notifyListeners();
    }
  }

  Future<void> addPayment(String groupName, String payment) async {
    final group = _groupsBox.get(groupName);
    if (group != null) {
      group.paymentHistory.add(payment);
      await group.save();
      notifyListeners();
    }
  }

  Future<void> close() async {
    await _groupsBox.close();
  }
}