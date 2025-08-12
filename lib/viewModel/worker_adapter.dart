

import 'package:hive/hive.dart';

part 'worker_adapter.g.dart';





@HiveType(typeId: 1)
class Worker {
  @HiveField(0)
  final String name;
  
  @HiveField(1)
  final String groupName;
  
  @HiveField(2)
  final String deductions;
  
  @HiveField(3)
  final List<String> selectedDays;
  
  @HiveField(4)
  final String earnings;
  
  @HiveField(5)
  final String total;
  
  @HiveField(6)
  final String weekRange;

  @HiveField(7)  
  final String dailyPay;

  @HiveField(8)  
  final int workerCount;

  Worker({
    required this.name,
    required this.groupName,
    this.deductions = '0',
    this.selectedDays = const [],
    this.earnings = '0',
    this.total = '0',
    required this.weekRange,
    this.dailyPay = '0',
    this.workerCount = 0,
  });

  // Added copyWith method
  Worker copyWith({
    String? name,
    String? groupName,
    String? deductions,
    List<String>? selectedDays,
    String? earnings,
    String? total,
    String? weekRange,
    String? dailyPay,
    int? workerCount,
  }) {
    return Worker(
      name: name ?? this.name,
      groupName: groupName ?? this.groupName,
      deductions: deductions ?? this.deductions,
      selectedDays: selectedDays ?? this.selectedDays,
      earnings: earnings ?? this.earnings,
      total: total ?? this.total,
      weekRange: weekRange ?? this.weekRange,
      dailyPay: dailyPay ?? this.dailyPay,
      workerCount: workerCount ?? this.workerCount,
    );
  }
}