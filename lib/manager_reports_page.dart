import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'styled_app_bar.dart';

class ManagerReportsPage extends StatefulWidget {
  const ManagerReportsPage({super.key});

  @override
  State<ManagerReportsPage> createState() => _ManagerReportsPageState();
}

class _ManagerReportsPageState extends State<ManagerReportsPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 6));
  DateTime _endDate = DateTime.now();

  bool _loading = false;
  String? _errorMessage;
  String _companyName = 'Your Company';

  List<_EmployeeReport> _reports = [];
  double _totalHours = 0;
  double _totalTips = 0;

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  String _dateLabel(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString()) ?? 0;
  }

  Future<DateTime?> _pickGreenDate(DateTime initialDate) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF388E3C),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF388E3C),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate = isStart ? _startDate : _endDate;
    final selected = await _pickGreenDate(initialDate);

    if (selected == null) {
      return;
    }

    setState(() {
      if (isStart) {
        _startDate = selected;
        if (_startDate.isAfter(_endDate)) {
          _endDate = _startDate;
        }
      } else {
        _endDate = selected;
        if (_endDate.isBefore(_startDate)) {
          _startDate = _endDate;
        }
      }
    });
  }

  Future<void> _generateReport() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'You must be logged in.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final db = FirebaseFirestore.instance;
      final userDoc = await db.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final companyId = (userData?['companyId'] ?? '').toString();

      if (companyId.isEmpty) {
        throw Exception('No company assigned to this manager account.');
      }

      final companyDoc = await db.collection('companies').doc(companyId).get();
      final companyData = companyDoc.data();

      final start = DateTime(_startDate.year, _startDate.month, _startDate.day);
      final end = DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        23,
        59,
        59,
      );

      final employeesSnap = await db
          .collection('companies')
          .doc(companyId)
          .collection('employees')
          .get();

      final worklogsSnap = await db
          .collection('companies')
          .doc(companyId)
          .collection('worklogs')
          .where('workDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('workDate', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      final Map<String, _EmployeeReport> reportMap = {};

      for (final employeeDoc in employeesSnap.docs) {
        final data = employeeDoc.data();
        reportMap[employeeDoc.id] = _EmployeeReport(
          employeeUid: employeeDoc.id,
          name: (data['name'] ?? 'Employee').toString(),
          email: (data['email'] ?? '').toString(),
          totalHours: 0,
          totalTips: 0,
        );
      }

      for (final logDoc in worklogsSnap.docs) {
        final data = logDoc.data();
        final employeeUid = (data['employeeUid'] ?? '').toString();
        if (employeeUid.isEmpty) {
          continue;
        }

        final current =
            reportMap[employeeUid] ??
            _EmployeeReport(
              employeeUid: employeeUid,
              name: (data['employeeName'] ?? 'Employee').toString(),
              email: (data['employeeEmail'] ?? '').toString(),
              totalHours: 0,
              totalTips: 0,
            );

        reportMap[employeeUid] = current.copyWith(
          totalHours: current.totalHours + _toDouble(data['hours']),
          totalTips: current.totalTips + _toDouble(data['tips']),
        );
      }

      final reports = reportMap.values.toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      final totalHours = reports.fold<double>(
        0,
        (runningTotal, item) => runningTotal + item.totalHours,
      );
      final totalTips = reports.fold<double>(
        0,
        (runningTotal, item) => runningTotal + item.totalTips,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _companyName = (companyData?['name'] ?? 'Your Company').toString();
        _reports = reports;
        _totalHours = totalHours;
        _totalTips = totalTips;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: buildPrimaryAppBar(context, title: 'Generate Reports'),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _companyName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select dates to generate total hours and tip amounts for each employee.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(isStart: true),
                        icon: const Icon(Icons.calendar_today),
                        label: Text('Start: ${_dateLabel(_startDate)}'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(isStart: false),
                        icon: const Icon(Icons.calendar_month),
                        label: Text('End: ${_dateLabel(_endDate)}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: _loading ? null : _generateReport,
                    icon: const Icon(Icons.edit_document, color: Colors.white),
                    label: const Text(
                      'Generate Report',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryColumn('Employees', _reports.length.toString()),
                _summaryColumn('Total Hours', _totalHours.toStringAsFixed(2)),
                _summaryColumn(
                  'Total Tips',
                  '\$${_totalTips.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _reports.isEmpty
                ? const Center(
                    child: Text(
                      'No employees or logs found in this date range.',
                    ),
                  )
                : ListView.builder(
                    itemCount: _reports.length,
                    itemBuilder: (context, index) {
                      final report = _reports[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFFC8E6C9),
                              child: Text(
                                report.name.isEmpty
                                    ? '?'
                                    : report.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    report.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (report.email.isNotEmpty)
                                    Text(
                                      report.email,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Hours: ${report.totalHours.toStringAsFixed(2)}',
                                ),
                                Text(
                                  'Tips: \$${report.totalTips.toStringAsFixed(2)}',
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _summaryColumn(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _EmployeeReport {
  const _EmployeeReport({
    required this.employeeUid,
    required this.name,
    required this.email,
    required this.totalHours,
    required this.totalTips,
  });

  final String employeeUid;
  final String name;
  final String email;
  final double totalHours;
  final double totalTips;

  _EmployeeReport copyWith({
    String? employeeUid,
    String? name,
    String? email,
    double? totalHours,
    double? totalTips,
  }) {
    return _EmployeeReport(
      employeeUid: employeeUid ?? this.employeeUid,
      name: name ?? this.name,
      email: email ?? this.email,
      totalHours: totalHours ?? this.totalHours,
      totalTips: totalTips ?? this.totalTips,
    );
  }
}
