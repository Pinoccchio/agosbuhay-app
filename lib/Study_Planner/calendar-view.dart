import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CalendarView extends StatefulWidget {
  final String studentNumber;

  const CalendarView({Key? key, required this.studentNumber}) : super(key: key);

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<Map<String, dynamic>>> _events;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _events = {};
    _fetchEvents();
  }

  void _fetchEvents() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.studentNumber)
        .collection('to-do-files')
        .get();

    final events = <DateTime, List<Map<String, dynamic>>>{};

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final startTime = (data['startTime'] as Timestamp).toDate();
      final endTime = (data['endTime'] as Timestamp).toDate();
      final subject = data['subject'] as String;
      final status = data['status'] as String;

      final eventDate = DateTime(startTime.year, startTime.month, startTime.day);
      if (events[eventDate] == null) events[eventDate] = [];
      events[eventDate]!.add({
        'subject': subject,
        'startTime': startTime,
        'endTime': endTime,
        'status': status,
      });
    }

    setState(() {
      _events = events;
    });
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Schedule Calendar',
          style: GoogleFonts.almarai(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Colors.red),
              holidayTextStyle: TextStyle(color: Colors.blue[800]),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView(
              children: _getEventsForDay(_selectedDay)
                  .map((event) => _buildEventTile(event))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTile(Map<String, dynamic> event) {
    final startTime = event['startTime'] as DateTime;
    final endTime = event['endTime'] as DateTime;
    final subject = event['subject'] as String;
    final status = event['status'] as String;

    Color statusColor;
    switch (status) {
      case 'To Do':
        statusColor = const Color(0xFFC4D7FF);
        break;
      case 'Missed':
        statusColor = Colors.red;
        break;
      case 'Completed':
        statusColor = const Color(0xFF57E597);
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: Container(
          width: 12,
          color: statusColor,
        ),
        title: Text(subject, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${DateFormat.jm().format(startTime)} - ${DateFormat.jm().format(endTime)}',
          style: GoogleFonts.lato(),
        ),
        trailing: Text(status, style: GoogleFonts.lato(color: statusColor)),
      ),
    );
  }
}
