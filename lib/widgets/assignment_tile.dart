import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/assignment.dart';

Color statusColor(Assignment a) {
  final now = DateTime.now();
  if (a.status == 'Submitted') return Colors.green;
  if (a.dueDateTime.isBefore(now)) return Colors.red;
  final diff = a.dueDateTime.difference(now);
  if (diff.inHours <= 48) return Colors.orange;
  return Colors.blueGrey;
}

class AssignmentTile extends StatelessWidget {
  final Assignment assignment;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const AssignmentTile({
    Key? key,
    required this.assignment,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy-MM-dd HH:mm');
    final color = statusColor(assignment);
    return Card(
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: CircleAvatar(backgroundColor: color, child: Text(assignment.courseCode.substring(0,1).toUpperCase())),
        title: Text('${assignment.courseCode} - ${assignment.title}'),
        subtitle: Text('${fmt.format(assignment.dueDateTime)} • ${assignment.status}'),
        trailing: Icon(Icons.insert_drive_file, color: assignment.status == 'Submitted' ? Colors.green : null),
      ),
    );
  }
}
