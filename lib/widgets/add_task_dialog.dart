 

import 'package:flutter/material.dart';
import 'package:prodigenious/services/firestore_task_services.dart';
import 'package:prodigenious/services/notificaiton_service.dart';

void showAddTaskDialog(
  BuildContext context,
  String username,
  String userEmail, {
  String? existingTaskId,
  String? initialTask,
  String? initialPriority,
  DateTime? initialDueDate,
}) {
  TextEditingController taskController =
      TextEditingController(text: initialTask ?? '');
  String selectedPriority = initialPriority ?? "High";
  DateTime? selectedDueDate = initialDueDate;
  TimeOfDay? selectedTime = initialDueDate != null
      ? TimeOfDay(hour: initialDueDate.hour, minute: initialDueDate.minute)
      : null;

  bool isEditing = existingTaskId != null;

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        backgroundColor: Color(0xFFA558E0),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.85,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? "Update Task" : "Add New Task Manually",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
                Divider(color: Colors.white, thickness: 1),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Enter The Task Name",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: taskController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "e.g., Complete Flutter UI",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Choose Priority",
                              style: TextStyle(color: Colors.white)),
                          SizedBox(height: 5),
                          DropdownButtonFormField<String>(
                            value: selectedPriority,
                            icon: Icon(Icons.arrow_drop_down),
                            dropdownColor: Colors.white,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (value) {
                              selectedPriority = value!;
                            },
                            items: ["High", "Medium", "Low"]
                                .map((priority) => DropdownMenuItem(
                                      value: priority,
                                      child: Text(priority),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Set Due Date",
                              style: TextStyle(color: Colors.white)),
                          SizedBox(height: 5),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: selectedDueDate ?? DateTime.now(),
                                firstDate: DateTime(2023),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                selectedDueDate = pickedDate;
                              }
                            },
                            icon: Icon(Icons.calendar_today, size: 18),
                            label: Text("Date"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Select Time",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 5),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      selectedTime = pickedTime;
                    }
                  },
                  icon: Icon(Icons.access_time, size: 18),
                  label: Text("Select Time"),
                ),
                SizedBox(height: 20),
                Divider(color: Colors.white, thickness: 1),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (taskController.text.isEmpty ||
                        selectedDueDate == null ||
                        selectedTime == null) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Missing Details"),
                          content: Text(
                              "Please enter all the required task details."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text("OK"),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    String taskTitle = taskController.text.trim();

                    DateTime dueDateTime = DateTime(
                      selectedDueDate!.year,
                      selectedDueDate!.month,
                      selectedDueDate!.day,
                      selectedTime!.hour,
                      selectedTime!.minute,
                      0,
                    );

                    if (isEditing) {
                      await updateTaskInFirestore(
                        existingTaskId!,
                        taskTitle,
                        selectedPriority,
                        dueDateTime,
                      );
                    } else {
                      await addTaskToFirestore(
                        taskTitle,
                        selectedPriority,
                        dueDateTime,
                        username,
                        userEmail,
                      );
                    }

                    DateTime now = DateTime.now();
                    DateTime oneDayBefore =
                        dueDateTime.subtract(Duration(days: 1));
                    DateTime oneHourBefore =
                        dueDateTime.subtract(Duration(hours: 1));

                    if (!isEditing) {
                      if (oneDayBefore.isAfter(now.add(Duration(minutes: 1)))) {
                        await NotificationService.scheduleNotification(
                          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                          title: "Task Reminder",
                          body: "Your task '$taskTitle' is due tomorrow!",
                          scheduledDateTime: oneDayBefore,
                          userEmail: userEmail,
                        );
                      } else if (oneHourBefore
                          .isAfter(now.add(Duration(minutes: 1)))) {
                        await NotificationService.scheduleNotification(
                          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                          title: "Upcoming Task",
                          body:
                              "Reminder: Your task '$taskTitle' is due in an hour!",
                          scheduledDateTime: oneHourBefore,
                          userEmail: userEmail,
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Task Added"),
                              content: Text(
                                  "Notification not scheduled because the time is too close."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }

                    Navigator.of(context).pop(); // close dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(isEditing ? "Update Task" : "Add Task"),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
