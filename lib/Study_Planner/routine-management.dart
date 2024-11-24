import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'calendar-view.dart';
import 'update_data.dart';

class RoutineManagement extends StatefulWidget {
  final String studentNumber;

  const RoutineManagement({Key? key, required this.studentNumber}) : super(key: key);

  @override
  _RoutineManagementState createState() => _RoutineManagementState();
}

class _RoutineManagementState extends State<RoutineManagement> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _taskCheckTimer;

  @override
  void initState() {
    super.initState();
    _startRealTimeTaskChecker();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _taskCheckTimer?.cancel();
    super.dispose();
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
          'Routine Management',
          style: GoogleFonts.almarai(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarView(studentNumber: widget.studentNumber),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[400],
          indicator: BoxDecoration(
            color: Color(0xFF2FD1C5),
            borderRadius: BorderRadius.circular(8),
          ),
          tabs: [
            _buildTab('To Do'),
            _buildTab('Missed'),
            _buildTab('Completed'),
          ],
        ),
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            _buildNewTaskButton(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTaskList(context, 'To Do'),
                  _buildTaskList(context, 'Missed'),
                  _buildTaskList(context, 'Completed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewTaskButton() {
    return Container(
      margin: EdgeInsets.only(top: 10, right: 24),
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: () => _showNewTaskDialog(context),
        icon: Icon(Icons.add, color: Color(0xFF57E597)),
        label: Text(
          'New Task',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFF57E597),
          ),
        ),
      ),
    );
  }

  void _showNewTaskDialog(BuildContext context) {
    final subjectController = TextEditingController();
    final startDateTimeController = TextEditingController();
    final endDateTimeController = TextEditingController();
    final detailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenSize = MediaQuery.of(context).size;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Color(0xFF000000),
          child: Container(
            width: screenSize.width * 0.9,
            height: screenSize.height * 0.7,
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Create a Task',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _buildDialogTextField('Subject', controller: subjectController),
                  SizedBox(height: 20),
                  _buildDateTimePicker('Start Date & Time', controller: startDateTimeController, context: context),
                  SizedBox(height: 20),
                  _buildDateTimePicker('End Date & Time', controller: endDateTimeController, context: context),
                  SizedBox(height: 20),
                  _buildDialogTextField('Details', controller: detailsController),
                  SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2FD1C5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        if (subjectController.text.isEmpty ||
                            startDateTimeController.text.isEmpty ||
                            endDateTimeController.text.isEmpty ||
                            detailsController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please fill in all fields.'), backgroundColor: Colors.red),
                          );
                          return;
                        }

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.studentNumber)
                            .collection('to-do-files')
                            .add({
                          'subject': subjectController.text,
                          'startTime': DateTime.parse(startDateTimeController.text),
                          'endTime': DateTime.parse(endDateTimeController.text),
                          'details': detailsController.text,
                          'status': 'To Do',
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Text(
                          'Create',
                          style: GoogleFonts.almarai(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogTextField(String labelText, {required TextEditingController controller}) {
    return TextField(
      controller: controller,
      style: GoogleFonts.lato(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.lato(color: Color(0xFF585A66)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE4EDFF)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF57E597)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(String labelText, {required TextEditingController controller, required BuildContext context}) {
    return TextField(
      controller: controller,
      readOnly: true,
      style: GoogleFonts.lato(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.lato(color: Color(0xFF585A66)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE4EDFF)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF57E597)),
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: Icon(Icons.calendar_today, color: Colors.white),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );

        if (pickedDate != null) {
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );

          if (pickedTime != null) {
            final DateTime finalDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
            controller.text = finalDateTime.toIso8601String();
          }
        }
      },
    );
  }

  Widget _buildTab(String text) {
    return Tab(
      child: Container(
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, String taskType) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentNumber)
          .collection('to-do-files')
          .where('status', isEqualTo: taskType)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/animated_icon/empty-animation.json', width: 200, height: 200),
                SizedBox(height: 20),
                Text('No tasks available.', style: TextStyle(color: Colors.white)),
              ],
            ),
          );
        }

        DateTime currentTime = DateTime.now();
        final DateFormat dateFormat = DateFormat('MMM d, yyyy');
        final DateFormat timeFormat = DateFormat('h:mm a');

        return SingleChildScrollView(
          child: Column(
            children: snapshot.data!.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;

              DateTime endTime = (data['endTime'] as Timestamp).toDate();
              String endTimeString = '${dateFormat.format(endTime)} ${timeFormat.format(endTime)}';

              DateTime startTime = (data['startTime'] as Timestamp).toDate();
              String startTimeString = '${dateFormat.format(startTime)} ${timeFormat.format(startTime)}';

              if (taskType != 'Completed' && endTime.isBefore(currentTime)) {
                _markTaskAsMissed(doc.id);
              }

              return _buildSection(
                context,
                sectionColor: _getColorForTaskType(taskType),
                time: '$startTimeString - $endTimeString',
                title: data['subject'],
                description: data['details'],
                svgAsset: 'assets/vectors/vector_2_x2.svg',
                onActionTap: () => _showActionMenu(context, doc.id),
                onCheckTap: () => _markTaskAsCompleted(doc.id),
                showCheckIcon: taskType != 'Completed',
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _startRealTimeTaskChecker() {
    _taskCheckTimer = Timer.periodic(Duration(minutes: 1), (timer) async {
      QuerySnapshot tasks = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentNumber)
          .collection('to-do-files')
          .where('status', isEqualTo: 'To Do')
          .get();

      DateTime currentTime = DateTime.now();
      tasks.docs.forEach((doc) {
        var data = doc.data() as Map<String, dynamic>;
        DateTime endTime = (data['endTime'] as Timestamp).toDate();

        if (endTime.isBefore(currentTime)) {
          _markTaskAsMissed(doc.id);
        }
      });
    });
  }

  void _markTaskAsMissed(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentNumber)
          .collection('to-do-files')
          .doc(docId)
          .update({'status': 'Missed'});
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  void _markTaskAsCompleted(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentNumber)
          .collection('to-do-files')
          .doc(docId)
          .update({'status': 'Completed'});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task marked as completed!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  Widget _buildSection(
      BuildContext context, {
        required Color sectionColor,
        required String time,
        required String title,
        required String description,
        required String svgAsset,
        required VoidCallback onActionTap,
        VoidCallback? onCheckTap,
        bool showCheckIcon = true,
      }) {
    return Container(
      margin: EdgeInsets.fromLTRB(22, 0, 24, 26),
      decoration: BoxDecoration(
        border: Border.all(color: sectionColor),
        borderRadius: BorderRadius.circular(12),
        color: Color(0xFFFFFFFF),

        boxShadow: [
          BoxShadow(
            color: Color(0x0D1C252C),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -20,
            top: 0,
            bottom: 0,
            child: Container(
              width: 8,
              decoration: BoxDecoration(
                color: sectionColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(24, 11, 24, 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        svgAsset,
                        width: 16,
                        height: 16,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              time,
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                height: 1.4,
                                color: Color(0xE59A9A9A),
                              ),
                            ),
                            SizedBox(height: 7),
                            Text(
                              title,
                              style: GoogleFonts.almarai(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                height: 1.2,
                                color: Color(0xFF292929),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              description,
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                height: 1.2,
                                color: Color(0xFF1C252C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Row(
                  children: [
                    if (showCheckIcon)
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green, size: 24),
                        onPressed: onCheckTap,
                      ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: onActionTap,
                      child: Icon(
                        Icons.more_vert,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showActionMenu(BuildContext context, String docId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: Colors.white),
                title: Text(
                  'Edit',
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateDataScreen(
                        studentNumber: widget.studentNumber,
                        docId: docId,
                      ),
                    ),
                  );
                },
              ),
              Divider(color: Colors.grey[700]),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.white),
                title: Text(
                  'Delete',
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteTask(context, docId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteTask(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentNumber)
          .collection('to-do-files')
          .doc(docId)
          .delete();

      Fluttertoast.showToast(
        msg: 'Task deleted successfully.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to delete task.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}

Color _getColorForTaskType(String taskType) {
  switch (taskType) {
    case 'To Do':
      return Color(0xFFC4D7FF);
    case 'Missed':
      return Colors.red;
    case 'Completed':
      return Color(0xFF57E597);
    default:
      return Colors.grey;
  }
}