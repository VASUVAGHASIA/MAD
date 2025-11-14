import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/assignment.dart';

class AddEditScreen extends StatefulWidget {
  final Assignment? assignment;
  const AddEditScreen({Key? key, this.assignment}) : super(key: key);

  @override
  _AddEditScreenState createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _courseController;
  late TextEditingController _titleController;
  late TextEditingController _descController;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _status = 'Not started';

  @override
  void initState() {
    super.initState();
    final a = widget.assignment;
    _courseController = TextEditingController(text: a?.courseCode ?? '');
    _titleController = TextEditingController(text: a?.title ?? '');
    _descController = TextEditingController(text: a?.description ?? '');
    if (a != null) {
      _selectedDate = a.dueDateTime;
      _selectedTime = TimeOfDay.fromDateTime(a.dueDateTime);
      _status = a.status;
    }
  }

  @override
  void dispose() {
    _courseController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  Future _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _selectedTime);
    if (t != null) setState(() => _selectedTime = t);
  }

  DateTime get _combined => DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

  Future _save() async {
    if (!_formKey.currentState!.validate()) return;
    final a = Assignment(
      id: widget.assignment?.id,
      courseCode: _courseController.text.trim(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      dueDateTime: _combined,
      status: _status,
    );
    if (widget.assignment == null) {
      await DatabaseHelper.instance.create(a);
    } else {
      await DatabaseHelper.instance.update(a);
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy-MM-dd');
    final timeFmt = _selectedTime.format(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.assignment == null ? 'Add Assignment' : 'Edit Assignment')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _courseController,
                decoration: const InputDecoration(labelText: 'Course Code'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Assignment Title'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text('Due Date'),
                      subtitle: Text(fmt.format(_selectedDate)),
                      onTap: _pickDate,
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text('Due Time'),
                      subtitle: Text(timeFmt),
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['Not started', 'In progress', 'Submitted']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _status = v ?? 'Not started'),
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
