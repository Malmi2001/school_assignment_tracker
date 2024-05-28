import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_assignment_tracker/models/models.dart';
import 'package:school_assignment_tracker/pages/average_marks.dart';
import 'package:school_assignment_tracker/pages/subject_marks.dart';
import 'package:school_assignment_tracker/services/database_helper.dart';


class StudentDetailsScreen extends StatefulWidget {
  final Student? student;

  const StudentDetailsScreen({super.key, this.student});

  @override
  _StudentDetailsScreenState createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _databaseHelper = DatabaseHelper();
  final _termMarks = {
    'Term 1': <Map<String, dynamic>>[],
    'Term 2': <Map<String, dynamic>>[],
    'Term 3': <Map<String, dynamic>>[],
    'Term 4': <Map<String, dynamic>>[],
  };

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      _nameController.text = widget.student!.name;
      _emailController.text = widget.student!.email;
      _contactController.text = widget.student!.contact;
      _loadStudentMarks();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentMarks() async {
    for (final term in _termMarks.keys) {
      final marks = await _databaseHelper.getMarks(widget.student!.id!, term);
      _termMarks[term] = marks.map((mark) {
        return {
          'Biology': mark['mark'],
          'Physics': mark['mark'],
          'Chemistry': mark['mark'],
        };
      }).toList();
    }
    setState(() {});
  }

  Future<void> _saveStudent() async {
    if (_formKey.currentState!.validate()) {
      final student = Student(
        id: widget.student?.id,
        name: _nameController.text,
        email: _emailController.text,
        contact: _contactController.text,
      );

      try {
        if (widget.student == null) {
          print('Inserting new student');
          final studentId = await _databaseHelper.insertStudent(student.toMap());
          print('New student inserted with ID: $studentId');
          // Insert marks for the new student
          for (final termMarks in _termMarks.values) {
            for (final subjectAndMark in termMarks) {
              subjectAndMark['studentId'] = studentId;
              await _databaseHelper.insertMark(subjectAndMark);
            }
          }
        } else {
          print('Updating existing student');
          await _databaseHelper.updateStudent(student.toMap());
          // Delete existing marks and insert new marks of  student
          await _databaseHelper.deleteMarks(student.id!);
          for (final termMarks in _termMarks.values) {
            for (final subjectAndMark in termMarks) {
              subjectAndMark['studentId'] = student.id;
              await _databaseHelper.insertMark(subjectAndMark);
            }
          }
        }

        Get.snackbar(
          'Success',
          'Student saved successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } catch (e) {
        if (kDebugMode) {
          print('Error saving student: $e');
        }
        Get.snackbar(
          'Error',
          'Failed to save student',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      print('Form validation failed');
    }
  }

  Future<void> _addSubjectMarksForTerm(String term) async {
    if (_formKey.currentState!.validate()) {
      final result = await Get.to(() => SubjectMarksScreen(
            term: term,
            subjectAndMark: const {},
          ));
      if (result != null) {
        setState(() {
          _termMarks[term]!.add(result);
        });
      }
    }
  }

  double _calculateAverageMarks(List<Map<String, dynamic>> subjectMarks) {
    if (subjectMarks.isEmpty) return 0.0;
    double totalMarks = 0;
    for (final subjectMark in subjectMarks) {
      totalMarks += subjectMark['Biology']! +
          subjectMark['Physics']! +
          subjectMark['Chemistry']!;
    }
    return totalMarks / (subjectMarks.length * 3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student == null ? 'Add Student' : 'Edit Student'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              if (widget.student != null) {
                Get.to(() => AverageMarksScreen(student: widget.student!));
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.pink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      filled: true,
                      fillColor: const Color.fromARGB(255, 105, 146, 228),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: const Color.fromARGB(255, 105, 146, 228),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _contactController,
                    decoration: InputDecoration(
                      labelText: 'Contact Number',
                      filled: true,
                      fillColor: const Color.fromARGB(255, 105, 146, 228),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a contact number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      ..._termMarks.keys.map((term) {
                        return ElevatedButton(
                          onPressed: () => _addSubjectMarksForTerm(term),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 16.0,
                            ),
                            child: Text(
                              'Add Marks for $term',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: _termMarks.length,
                      itemBuilder: (context, index) {
                        final term = _termMarks.keys.toList()[index];
                        final subjectMarks = _termMarks[term]!;
                        final averageMarks =
                            _calculateAverageMarks(subjectMarks);
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text('$term Average Marks'),
                            subtitle: Text(
                                'Marks: ${subjectMarks.map((mark) => '${mark['Biology']}, ${mark['Physics']}, ${mark['Chemistry']}').join(', ')}'),
                            trailing: Text(averageMarks.toStringAsFixed(2)),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  ElevatedButton(
                    onPressed: _saveStudent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 24.0,
                      ),
                      child: Text(
                        widget.student == kNoDefaultValue
                            ? 'Add Student'
                            : 'Update Student',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
