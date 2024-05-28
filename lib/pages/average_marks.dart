import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_assignment_tracker/models/models.dart';
import 'package:school_assignment_tracker/services/database_helper.dart';


class AverageMarksScreen extends StatefulWidget {
  final Student student;

  const AverageMarksScreen({super.key, required this.student});

  @override
  _AverageMarksScreenState createState() => _AverageMarksScreenState();
}

class _AverageMarksScreenState extends State<AverageMarksScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final _termAverageMarks = <String, double>{};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAverageMarks();
  }

  Future<void> _loadAverageMarks() async {
    try {
      for (final term in ['Term 1', 'Term 2', 'Term 3', 'Term 4']) {
        final averageMarks = await _databaseHelper.calculateAverageMarks(
          widget.student.id!,
          term,
        );
        _termAverageMarks[term] = averageMarks;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load average marks: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Average Marks for ${widget.student.name}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.pink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    ..._termAverageMarks.entries.map((entry) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(
                            '${entry.key} Average Marks',
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(entry.value.toStringAsFixed(2)),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
    );
  }
}
