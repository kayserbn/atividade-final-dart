import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  int hour;

  @HiveField(3)
  int minute;

  /// Dias da semana: 1=Segunda, 2=Terça, ..., 7=Domingo
  @HiveField(4)
  List<int> weekdays;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.hour,
    required this.minute,
    required this.weekdays,
    this.isCompleted = false,
    required this.createdAt,
  });
}
