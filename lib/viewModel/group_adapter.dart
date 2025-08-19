import 'package:hive/hive.dart';



@HiveType(typeId: 0)
class Group {
  @HiveField(0)
  final String name;
  
  @HiveField(1)
  final DateTime createdAt;

  Group(this.name, this.createdAt);
}