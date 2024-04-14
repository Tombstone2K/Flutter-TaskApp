//Global Variables along with Riverpod Notifiers
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'HiveStruct/TaskStruct.dart';



late Box taskBox;
Map<DateTime, List<TaskStruct>> groupedTasks = {};

void refreshData(){
  groupedTasks.clear();
  List<TaskStruct> allTasksList = taskBox.values.whereType<TaskStruct>().toList();
  allTasksList.forEach((task) {
    final date = DateTime(task.date!.year, task.date!.month, task.date!.day);
    groupedTasks.putIfAbsent(date, () => []).add(task);
  });
}

class MyGroupsChangeNotifier extends ChangeNotifier{


  MyGroupsChangeNotifier(){
    List<TaskStruct> allTasksList = taskBox.values.whereType<TaskStruct>().toList();
    allTasksList.forEach((task) {
      final date = DateTime(task.date!.year, task.date!.month, task.date!.day);
      groupedTasks.putIfAbsent(date, () => []).add(task);
    });

  }


  void saveTasks(TaskStruct newTask){
    if (newTask.date != null) {
      taskBox.put(newTask.id, newTask);
      final date = DateTime(newTask.date!.year, newTask.date!.month, newTask.date!.day);
      groupedTasks.putIfAbsent(date, () => []).add(newTask);
    }
  }
  //
  void updateTaskCompletion(DateTime date, int index, bool completed){
    groupedTasks[date]?[index].completed = completed;
    taskBox.put(groupedTasks[date]?[index].id, groupedTasks[date]?[index]);

  }

  void updateEntireTask(DateTime date, int index, TaskStruct newTask){
    deleteTask(date, index);
    saveTasks(newTask);
  }
  //
  void deleteTask(DateTime date, int index) {
    final deletedTask = groupedTasks[date]?.removeAt(index);

    if (deletedTask != null) {
      if (groupedTasks[date]!.isEmpty) {
        groupedTasks.remove(date);
      }
      taskBox.delete(deletedTask.id);
    }
  }

  void clearTasks(){
    taskBox.clear();
  }


}
final myGroupsChangeNotifierProvider = ChangeNotifierProvider<MyGroupsChangeNotifier>((ref){
  return MyGroupsChangeNotifier();
});


