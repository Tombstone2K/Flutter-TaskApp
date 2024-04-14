// Main Home Page
/**
 * List of all tasks datewise
 * Use FAB to add new tasks
 * Swipe left on task to delete
 * Swipe right on task to toggle completion state
 * Tap on task text to open edit dialog
 * Use Checkbox to toggle completion state
* */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'package:taskmgmt/HiveStruct/TaskStruct.dart';
import 'package:taskmgmt/reusable_widgets/reusable_widget.dart';
import 'package:taskmgmt/screens/signin_screen.dart';

import 'globalVar.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  late TextEditingController taskNameController;
  late TextEditingController taskDescController;
  late String dateSelected;
  DateTime? pickedDate;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    taskNameController = TextEditingController();
    taskDescController = TextEditingController();
    dateSelected = getHyphenDateString(DateTime.now());

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  // Popup Dialog to add/edit details of a task, includes two text fields and one date picker
  Future<TaskStruct?> openDialog(bool newOrEdit) => showDialog<TaskStruct>(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, StateSetter setState){
        return AlertDialog(
          title: newOrEdit ? Text("Enter a Task") : Text("Edit Task"),
          content: SizedBox(
            height: MediaQuery.of(context).size.width * 0.6,
            child: Column(
              children: [
                TextField(
                  // isDense: true,
                  // autofocus: true,
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'Task Name',
                    border: OutlineInputBorder(),
                  ),
                  controller: taskNameController,
                  // inputFormatters: [
                  //   FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  // ],
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  maxLines: 2, // Set the maximum number of lines
                  scrollPhysics: AlwaysScrollableScrollPhysics(),
                  // autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Task Description',
                    border: OutlineInputBorder(),
                  ),
                  controller: taskDescController,
                  onSubmitted: (_) => () {},
                  // inputFormatters: [
                  //   FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  // ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Date: ",
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        pickedDate = await pickDate();
                        if (pickedDate != null) {
                          dateSelected = getHyphenDateString(pickedDate);
                          setState(() {
                          });
                        }
                      },
                      child: Container(
                        height: 45,
                        width: 150,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                          Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                           dateSelected,
                          // dateSelected,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                taskNameController.clear();
                taskDescController.clear();
                dateSelected = getHyphenDateString(DateTime.now());;
                pickedDate = null;
                return;
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (taskNameController.text.trim() == "") {
                  Navigator.of(context).pop();
                  taskNameController.clear();
                  taskDescController.clear();
                  dateSelected = getHyphenDateString(DateTime.now());;
                  pickedDate = null;
                } else {
                  pickedDate ??= DateTime.now();
                  Navigator.of(context).pop(TaskStruct(
                      taskNameController.text, taskDescController.text,
                      date: pickedDate));
                  taskNameController.clear();
                  taskDescController.clear();
                  dateSelected = getHyphenDateString(DateTime.now());
                  pickedDate = null;
                }

                return;
              },
              child: newOrEdit ? Text("Add") : Text("Update"),
            ),
          ],
        );
      }
      );
    }
  );

  @override
  Widget build(BuildContext context) {
    final myGroupsChangeNotifier = ref.watch(myGroupsChangeNotifierProvider);
    AdaptiveThemeMode currentMode = AdaptiveTheme.of(context).mode;
    String modeText = '';

    // Dark Theme
    if (currentMode == AdaptiveThemeMode.system) {
      modeText = 'System';
    } else if (currentMode == AdaptiveThemeMode.light) {
      modeText = 'Light';
    } else if (currentMode == AdaptiveThemeMode.dark) {
      modeText = 'Dark';
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary, //change your color here
        ),
        title: Text(widget.title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
      body: Consumer(builder: (context, ref, child) {

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child:


              ListView.builder(
            itemCount: groupedTasks.length,
            itemBuilder: (context, index) {

              final sortedDates = groupedTasks.keys.toList()
                ..sort((a, b) => a.compareTo(b));
              // Get the date at the current index
              final date = sortedDates[index];
              final tasksForDate = groupedTasks[date]!;


              // Return a Column with the date as header followed by task list
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text(
                      genDateString(date),
                      style:
                          TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: tasksForDate.length,
                    itemBuilder: (context, index) {
                      final task = tasksForDate[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Dismissible(
                            key: Key(
                                task.id), // Provide a unique key for each item

                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.endToStart) {
                                return await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Delete Task?'),
                                      content: const Text(
                                          'Are you sure you want to delete this task?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('CANCEL'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text('DELETE'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else if (direction ==
                                  DismissDirection.startToEnd) {
                                setState(() {
                                  task.completed = !task.completed;
                                });
                                myGroupsChangeNotifier.updateTaskCompletion(date, index, task.completed);
                              }
                            },
                            onDismissed: (direction) {
                              if (direction == DismissDirection.endToStart) {
                                myGroupsChangeNotifier.deleteTask(date, index);
                                myGroupsChangeNotifier.notifyListeners();
                              } else if (direction ==
                                  DismissDirection.startToEnd) {}
                            },
                            background: Container(
                              color: Colors.green, // Background color when swiping right
                              alignment: Alignment.centerLeft,
                              child: const Padding(
                                padding: EdgeInsets.only(left: 16.0),
                                child:
                                    Icon(Icons.done_all, color: Colors.white),
                              ),
                            ),
                            secondaryBackground: Container(

                              color: Colors.red, // Background color when swiping left
                              alignment: Alignment.centerRight,
                              child: const Padding(
                                padding: EdgeInsets.only(right: 16.0),
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                            ),
                            child: Container(
                              // borderOnForeground: false,
                              margin: const EdgeInsets.only(
                                  left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: ListTile(
                                leading: Checkbox(
                                  value: task.completed,
                                  onChanged: (bool? value) {
                                    // Update the completed status of the task
                                    setState(() {
                                      task.completed = value ?? false;
                                    });
                                    myGroupsChangeNotifier.updateTaskCompletion(date, index, task.completed);
                                    // Add any additional logic you need here
                                  },
                                ),
                                title: GestureDetector(
                                  onTap: () async {
                                    taskNameController.text = task.name;
                                    taskDescController.text = task.description;
                                    dateSelected = getHyphenDateString(task!.date);
                                    TaskStruct? updatedTask = await openDialog(false);
                                    if (updatedTask != null ){
                                      myGroupsChangeNotifier.updateEntireTask(date, index, updatedTask);
                                      myGroupsChangeNotifier.notifyListeners();
                                    }
                                  },
                                    child: Text(task.name,
                                      style: task.completed ? TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      ) : TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        );
      }),
      // Drawer for LogOut and changing theme
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  const SizedBox(
                    height: 36,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tasky',
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Divider(
                    height: 2,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  const Expanded(
                      child: SizedBox(
                    height: 20,
                  )),
                  Divider(
                    height: 2,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  ListTile(
                    title: Text(
                      'Log Out',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    trailing: Icon(
                      Icons.logout,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onTap: () {
                      FirebaseAuth.instance.signOut().then((value) {
                        // myGroupsChangeNotifier.clearTasks();
                        snackBarMsg(context,"Signed Out");
                        // H.close();
                        groupedTasks.clear();
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => SignInScreen()));
                      });
                      // AdaptiveTheme.of(context).toggleThemeMode();
                      // Navigator.push(context, MaterialPageRoute(builder: (context)=>ReorderableListPage()));
                      // Handle item 1
                    },
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ListTile(
                      title: Text(
                        'Theme Mode: $modeText',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      trailing: Icon(
                        Icons.dark_mode,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      onTap: () {
                        AdaptiveTheme.of(context).toggleThemeMode();
                        // Navigator.push(context, MaterialPageRoute(builder: (context)=>ReorderableListPage()));
                        // Handle item 1
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      //FAB to add new task
      floatingActionButton: FloatingActionButton(
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () async {
          TaskStruct? newTask = await openDialog(true);
          if (newTask != null) {
            myGroupsChangeNotifier.saveTasks(newTask!);
            myGroupsChangeNotifier.notifyListeners();
          }
        },
        child: const Icon(Icons.add_task_outlined),
      ),
    );
  }


  Future<DateTime?> pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    return pickedDate;
  }

  String genDateString(DateTime date) {
    final monthMap = {
      1: 'Jan',
      2: 'Feb',
      3: 'Mar',
      4: 'Apr',
      5: 'May',
      6: 'Jun',
      7: 'Jul',
      8: 'Aug',
      9: 'Sep',
      10: 'Oct',
      11: 'Nov',
      12: 'Dec',
    };
    return '${date.day} ${monthMap[date.month]}, ${date.year}';

  }

  String getHyphenDateString( DateTime? tempDate){
    return '${tempDate?.day.toString().padLeft(2, '0')}-${tempDate?.month.toString().padLeft(2, '0')}-${tempDate?.year}';

  }
}
