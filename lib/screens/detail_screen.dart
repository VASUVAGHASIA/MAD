import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/assignment.dart';
import '../db/database_helper.dart';
import 'add_edit_screen.dart';

class DetailScreen extends StatefulWidget {
  final Assignment assignment;
  const DetailScreen({Key? key, required this.assignment}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Assignment _a;

  @override
  void initState() {
    super.initState();
    _a = widget.assignment;
  }

  Future _refresh() async {
    final updated = await DatabaseHelper.instance.readAssignment(_a.id!);
    if (updated != null) setState(() => _a = updated);
  }

  Future _edit() async {
    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditScreen(assignment: _a)));
    if (res == true) _refresh();
  }

  Future _changeStatus(String s) async {
    _a.status = s;
    await DatabaseHelper.instance.update(_a);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy-MM-dd HH:mm');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Detail'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _edit),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_a.courseCode} • ${_a.title}', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Due: ${fmt.format(_a.dueDateTime)}'),
            const SizedBox(height: 12),
            Text('Status: ${_a.status}'),
            const SizedBox(height: 12),
            const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(_a.description.isEmpty ? '(No description)' : _a.description),
            const SizedBox(height: 18),
            const Text('Change status:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Not started', 'In progress', 'Submitted'].map((s) {
                final selected = _a.status == s;
                return ElevatedButton(
                  onPressed: selected ? null : () => _changeStatus(s),
                  child: Text(s),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
