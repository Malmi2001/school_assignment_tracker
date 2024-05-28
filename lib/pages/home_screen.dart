import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_assignment_tracker/models/models.dart';
import 'package:school_assignment_tracker/pages/average_marks.dart';
import 'package:school_assignment_tracker/pages/student_details.dart';
import 'package:school_assignment_tracker/services/database_helper.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final students = <Student>[].obs;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final data = await dbHelper.getStudents();
    students.value = data
        .map((item) => Student(
              id: item['id'], // Ensure column names match your database schema
              name: item['name'],
              contact: item['contact'],
              email: item['email'],
            ))
        .toList();
  }

  Future<void> _addOrUpdateStudent({Student? student}) async {
    final result = await Get.to(() => StudentDetailsScreen(student: student));
    if (result == true) {
      await _loadStudents();
    }
  }

  Future<void> _deleteStudent(int id) async {
    await dbHelper.deleteStudent(id);
    await _loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'School Assessment Tracker',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 197, 162, 162),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 87, 215, 235), Color.fromARGB(199, 214, 92, 214)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Obx(
          () => ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    student.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'Contact: ${student.contact}\nEmail: ${student.email}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _addOrUpdateStudent(student: student),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteStudent(student.id!),
                      ),
                      IconButton(
                        icon: const Icon(Icons.bar_chart),
                        onPressed: () => Get.to(() => AverageMarksScreen(student: student)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateStudent(student: null),
        child: const Icon(Icons.add),
      ),
    );
  }
}