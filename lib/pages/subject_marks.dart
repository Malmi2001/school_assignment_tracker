import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubjectMarksScreen extends StatefulWidget {
  final String term;

  const SubjectMarksScreen({super.key, required this.term, required Map<String, dynamic> subjectAndMark});

  @override
  _SubjectMarksScreenState createState() => _SubjectMarksScreenState();
}

class _SubjectMarksScreenState extends State<SubjectMarksScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectControllers = {
    'Biology': TextEditingController(),
    'Physics': TextEditingController(),
    'Chemistry': TextEditingController(),
  };

  @override
  void dispose() {
    _subjectControllers.forEach((key, value) => value.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Subject Marks for ${widget.term}'),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ..._subjectControllers.entries.map((entry) {
                  return TextFormField(
                    controller: entry.value,
                    decoration: InputDecoration(
                      labelText: '${entry.key} Mark',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a mark';
                      }
                      final mark = int.tryParse(value);
                      if (mark == null || mark < 0 || mark > 100) {
                        return 'Mark must be between 0 and 100';
                      }
                      return null;
                    },
                  );
                }).toList(),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final subjectMarks = {
                        'Biology': int.parse(_subjectControllers['Biology']!.text),
                        'Physics': int.parse(_subjectControllers['Physics']!.text),
                        'Chemistry': int.parse(_subjectControllers['Chemistry']!.text),
                      };
                      Get.back(result: subjectMarks);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 24.0,
                    ),
                    child: Text(
                      'Add Subject Marks',
                      style: TextStyle(
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
    );
  }
}
