import 'package:flutter/foundation.dart';

class Assignment {
  int? id;
  String courseCode;
  String title;
  String description;
  DateTime dueDateTime;
  String status; // "Not started", "In progress", "Submitted"

  Assignment({
    this.id,
    required this.courseCode,
    required this.title,
    required this.description,
    required this.dueDateTime,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseCode': courseCode,
      'title': title,
      'description': description,
      'dueDateTime': dueDateTime.toIso8601String(),
      'status': status,
    };
  }

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'] as int?,
      courseCode: map['courseCode'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDateTime: DateTime.parse(map['dueDateTime']),
      status: map['status'] ?? 'Not started',
    );
  }
}
