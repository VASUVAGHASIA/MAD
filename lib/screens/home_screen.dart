import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/assignment.dart';
import '../widgets/assignment_tile.dart';
import 'add_edit_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Assignment> _assignments = [];
  List<Assignment> _filtered = [];
  String _search = '';
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future _load() async {
    final list = await DatabaseHelper.instance.readAllAssignments();
    setState(() {
      _assignments = list;
      _applySearchFilter();
    });
  }

  void _applySearchFilter() {
    final s = _search.toLowerCase();
    _filtered = _assignments.where((a) {
      final matchesSearch = a.courseCode.toLowerCase().contains(s) || a.title.toLowerCase().contains(s);
      bool matchesFilter = true;
      final now = DateTime.now();
      if (_filter == 'Due Today') {
        matchesFilter = a.dueDateTime.year == now.year && a.dueDateTime.month == now.month && a.dueDateTime.day == now.day;
      } else if (_filter == 'Overdue') {
        matchesFilter = a.dueDateTime.isBefore(now) && a.status != 'Submitted';
      } else if (_filter == 'Submitted') {
        matchesFilter = a.status == 'Submitted';
      }
      return matchesSearch && matchesFilter;
    }).toList();
    _filtered.sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));
  }

  void _onSearchChanged(String val) {
    setState(() {
      _search = val;
      _applySearchFilter();
    });
  }

  void _onFilterChanged(String val) {
    setState(() {
      _filter = val;
      _applySearchFilter();
    });
  }

  Future _navigateToAdd() async {
    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditScreen()));
    if (res == true) _load();
  }

  Future _navigateToDetail(Assignment a) async {
    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(assignment: a)));
    if (res == true) _load();
  }

  Future _deleteAssignment(int id) async {
    await DatabaseHelper.instance.delete(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy-MM-dd');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Tracker'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _navigateToAdd),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search by course or title',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Filter:'),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _filter,
                      items: ['All', 'Due Today', 'Overdue', 'Submitted']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => _onFilterChanged(v ?? 'All'),
                    ),
                    const Spacer(),
                    Text('Total: ${_filtered.length}'),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: _filtered.isEmpty
            ? ListView(
                children: [
                  SizedBox(height: 80),
                  Center(child: Text('No assignments. Tap + to add.')),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _filtered.length,
                itemBuilder: (context, i) {
                  final a = _filtered[i];
                  return AssignmentTile(
                    assignment: a,
                    onTap: () => _navigateToDetail(a),
                    onLongPress: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete assignment?'),
                        content: Text('${a.courseCode} - ${a.title}'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteAssignment(a.id!);
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}
