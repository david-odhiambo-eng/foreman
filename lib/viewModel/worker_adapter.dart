import 'package:hive/hive.dart';

part 'worker_adapter.g.dart';

@HiveType(typeId: 0)
class WorkerModel extends HiveObject {
  @HiveField(0)
  final String name;
  
  @HiveField(1)
  String deductions;
  
  @HiveField(2)
  List<String> selectedDays;
  
  @HiveField(3)
  String earnings;
  
  @HiveField(4)
  String total;
  
  @HiveField(5)
  String weekRange;

  WorkerModel({
    required this.name,
    this.deductions = '0',
    this.selectedDays = const [],
    this.earnings = '0',
    this.total = '0',
    required this.weekRange,
  });
}

@HiveType(typeId: 1)
class GroupModel extends HiveObject {
  @HiveField(0)
  final String groupName;
  
  @HiveField(1)
  List<WorkerModel> workers;
  
  @HiveField(2)
  List<String> paymentHistory;
  
  @HiveField(3)
  String currentDate;
  
  @HiveField(4)
  String currentDay;

  GroupModel({
    required this.groupName,
    this.workers = const [],
    this.paymentHistory = const [],
    required this.currentDate,
    required this.currentDay,
  });
}