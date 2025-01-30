import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class TimesheetScreen extends StatefulWidget {
  @override
  _TimesheetScreenState createState() => _TimesheetScreenState();
}

class _TimesheetScreenState extends State<TimesheetScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<TimeEntry>> _events = {};
  DateTime? _clockInTime;
  DateTime? _clockOutTime;
  bool _hasClockIn = false;
  bool _hasClockOut = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _events[DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day)] =
        [];
  }

  List<TimeEntry> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        // Reset clock in/out state when changing days
        if (!isSameDay(selectedDay, DateTime.now())) {
          _clockInTime = null;
          _clockOutTime = null;
          _hasClockIn = false;
          _hasClockOut = false;
        } else {
          // Check if there are existing clock events for today
          final todayEvents = _getEventsForDay(selectedDay);
          for (var event in todayEvents) {
            if (event.type == TimeEntryType.clockIn) {
              _clockInTime = event.timestamp;
              _hasClockIn = true;
            } else if (event.type == TimeEntryType.clockOut) {
              _clockOutTime = event.timestamp;
              _hasClockOut = true;
            }
          }
        }
      });
    }
  }

  String _calculateHours() {
    if (_clockInTime != null && _clockOutTime != null) {
      final difference = _clockOutTime!.difference(_clockInTime!);
      final hours = difference.inHours;
      final minutes = (difference.inMinutes % 60);
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    }
    return '--:--';
  }

  void _addTimeEntry(TimeEntryType type) {
    final now = DateTime.now();
    final entry = TimeEntry(
      type: type,
      timestamp: now,
    );

    setState(() {
      final normalizedDay =
          DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
      if (!_events.containsKey(normalizedDay)) {
        _events[normalizedDay] = [];
      }
      _events[normalizedDay]!.add(entry);

      if (type == TimeEntryType.clockIn) {
        _clockInTime = now;
        _hasClockIn = true;
      } else if (type == TimeEntryType.clockOut) {
        _clockOutTime = now;
        _hasClockOut = true;
      }
    });
  }

  bool _isDateSelectable(DateTime day) {
    final now = DateTime.now();
    return day.isBefore(DateTime(now.year, now.month, now.day + 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Timesheet'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) => _getEventsForDay(day),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Colors.red),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              disabledTextStyle: TextStyle(
                color: Colors.grey,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            enabledDayPredicate: _isDateSelectable,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
              CalendarFormat.twoWeeks: '2 weeks',
            },
          ),
          if (_hasClockIn && _hasClockOut)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Total Hours: ${_calculateHours()}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          Expanded(
            child: ValueListenableBuilder<List<TimeEntry>>(
              valueListenable: ValueNotifier(_getEventsForDay(_selectedDay!)),
              builder: (context, events, _) {
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        title: Text(
                          '${event.type.toString().split('.').last}: ${DateFormat('HH:mm').format(event.timestamp)}',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (isSameDay(_selectedDay, DateTime.now()))
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        onPressed: _hasClockIn
                            ? null
                            : () => _addTimeEntry(TimeEntryType.clockIn),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text('Clock in'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        onPressed: !_hasClockIn || _hasClockOut
                            ? null
                            : () => _addTimeEntry(TimeEntryType.clockOut),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text('Clock out'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add action
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

enum TimeEntryType {
  clockIn,
  clockOut,
}

class TimeEntry {
  final TimeEntryType type;
  final DateTime timestamp;

  TimeEntry({
    required this.type,
    required this.timestamp,
  });
}
