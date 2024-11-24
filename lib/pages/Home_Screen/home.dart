import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../Study_Planner/routine-management.dart';
import '../HeartRateScreen/heart_rate_screen.dart';
import '../portable-doc-reader.dart';
import 'menu_item.dart';

class Home extends StatefulWidget {
  final String email;

  const Home({Key? key, required this.email}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();
  String? _profileImageUrl;
  String _fullName = 'Guest';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterItems);
    _listenForUserData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    if (mounted) {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    }
  }

  void _listenForUserData() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.email)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        var user = snapshot.data()!;
        if (mounted) {
          setState(() {
            _profileImageUrl = user['profilePictureUrl'];
            _fullName = user['fullName'] ?? 'Guest';
          });
        }
      } else {
        Fluttertoast.showToast(
          msg: "User data does not exist.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AgosBuhay',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black, // Set app bar color to black
        elevation: 0, // Remove shadow
        actions: [
          IconButton(
            icon: Lottie.asset(
              'assets/animated_icon/wired-flat-268-avatar-man.json',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/profile',
                arguments: {
                  'email': widget.email,
                  'profilePictureUrl': _profileImageUrl,
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(color: Colors.black),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildWelcomeText(),
                    const SizedBox(height: 8),
                    _buildHeaderRow(),
                    const SizedBox(height: 24),
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    _buildMenuTitle(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              _buildMenuItems(context),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17),
                child: _buildTranscriptionsTitle(),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _buildTranscriptionsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildWelcomeText() {
    return Text(
      'Welcome to AgosBuhay',
      style: GoogleFonts.montserrat(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        height: 1.3,
        color: Colors.white,
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            _fullName.isNotEmpty ? _fullName.split(' ').first : 'Guest',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              fontSize: 32,
              height: 1.1,
              color: Colors.white,
            ),
          ),
        ),
        // Remove the GestureDetector for the avatar
        // If you want to add anything else, you can do it here.
      ],
    );
  }


  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(36),
      ),
      child: Row(
        children: [
          SvgPicture.asset('assets/vectors/vector_8_x2.svg', width: 18, height: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: GoogleFonts.poppins(fontSize: 16, color: const Color(0xFF949494)),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTitle() {
    return Text(
      'Menu',
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        height: 1.3,
        color: Colors.white,
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17),
        child: Row(
          children: [
            _buildMenuItem(
              context,
              'assets/animated_icon/study-planner-animated.json',
              'Routine\nManagement',
                  () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoutineManagement(studentNumber: widget.email),
                ),
              ),
            ),
            const SizedBox(width: 16),
            _buildMenuItem(
              context,
              'assets/animated_icon/pdf-reader-anim.json',
              'Portable-Document\nReader',
                  () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PortableDocReader(email: widget.email),
                ),
              ),
            ),
            const SizedBox(width: 16),
            _buildMenuItem(
              context,
              'assets/animated_icon/heart-rate-animation.json',
              'Heart Rate\nMonitoring',
                  () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HeartRateScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildMenuItem(BuildContext context, String iconPath, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: MenuItem(
        iconPath: iconPath,
        label: label,
      ),
    );
  }

  Widget _buildTranscriptionsTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Transcriptions',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            height: 1.3,
            color: Colors.white,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PortableDocReader(email: widget.email),
              ),
            );
          },
          child: Text(
            'See all',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              height: 1.1,
              color: const Color(0xFF73CBE6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTranscriptionsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.email)
          .collection('files')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/animated_icon/empty-animation.json', width: 200, height: 200),
                const SizedBox(height: 20),
                const Text('No files available.', style: TextStyle(color: Colors.white)),
              ],
            ),
          );
        }

        final files = snapshot.data!.docs;
        final filteredFiles = files.where((file) {
          final fileName = (file['fileName'] ?? '').toLowerCase();
          return fileName.contains(_searchQuery);
        }).toList();

        return ListView.builder(
          itemCount: filteredFiles.length,
          itemBuilder: (context, index) {
            final file = filteredFiles[index];
            final fileName = file['fileName'] ?? 'Unknown';
            final uploadedAt = file['uploadedAt'] != null
                ? _formatDate(file['uploadedAt'].toDate())
                : 'Unknown Date';
            final fileUrl = file['fileURL'] ?? '';

            return FileContainer(
              fileName: fileName,
              uploadedAt: uploadedAt,
              onTap: () {
                if (fileUrl.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FileDetailsPage(
                        fileName: fileName,
                        fileURL: fileUrl,
                      ),
                    ),
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: "File URL is missing.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              },
              onDelete: () async {
                await _showDeleteConfirmationDialog(context, file.id);
              },
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime dateTime) {
    final DateFormat formatter = DateFormat('MM/dd/yyyy \'at\' h:mm a');
    return formatter.format(dateTime);
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, String fileId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text('Delete File', style: TextStyle(color: Colors.white)),
          content: const Text('Are you really sure you want to delete this file?', style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.email)
                    .collection('files')
                    .doc(fileId)
                    .delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}