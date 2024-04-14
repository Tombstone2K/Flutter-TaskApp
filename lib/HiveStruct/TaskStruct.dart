// Custom Data Structure to store Tasks in Hive
import 'dart:math';

import 'package:hive/hive.dart';

part 'TaskStruct.g.dart';


@HiveType(typeId: 0) // Unique typeId for the Hive adapter
class TaskStruct extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime? date; // Making DateTime field optional

  @HiveField(4)
  bool completed; // New boolean property

  TaskStruct(this.name, this.description, {this.date, this.completed = false}) {
    id = _generateRandomId();
  }

  String _generateRandomId() {
    // Generate a random 6-character alphanumeric ID
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(
      6,
          (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ));
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'date': date?.millisecondsSinceEpoch, // Convert DateTime to milliseconds since epoch
      'completed': completed,
    };
  }

  // Factory method to create TaskStruct object from a Map
  factory TaskStruct.fromMap(Map<String, dynamic> map) {
    return TaskStruct(
      map['name'],
      map['description'],
      date: map['date'] != null ? DateTime.fromMillisecondsSinceEpoch(map['date']) : null,
      completed: map['completed'],
    );
  }
}
