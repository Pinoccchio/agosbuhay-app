import 'package:flutter/material.dart';
import 'package:heart_bpm/heart_bpm.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

class HeartRateScreen extends StatefulWidget {
  const HeartRateScreen({Key? key}) : super(key: key);

  @override
  State<HeartRateScreen> createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen> with TickerProviderStateMixin {
  List<SensorValue> data = [];
  int? bpmValue;
  AnimationController? _animationController;
  bool isMeasuring = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimationController();
  }

  void _initializeAnimationController() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController?.repeat(reverse: true);
  }

  @override
  void dispose() {
    _disposeAnimationController();
    super.dispose();
  }

  void _disposeAnimationController() {
    _animationController?.stop();
    _animationController?.dispose();
    _animationController = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!ModalRoute.of(context)!.isCurrent) {
      _disposeAnimationController();
    }
  }

  String getHeartRateDescription(int? bpm) {
    if (bpm == null) return "Place your finger on the camera to begin";
    if (bpm < 60) return "Your heart rate is low (bradycardia). This could be normal for athletes, but consult a doctor if you're experiencing symptoms.";
    if (bpm >= 60 && bpm <= 100) return "Your heart rate is within the normal resting range for adults. Keep up the good work!";
    if (bpm > 100 && bpm <= 120) return "Your heart rate is slightly elevated. This could be due to stress, caffeine, or recent physical activity.";
    if (bpm > 120) return "Your heart rate is high (tachycardia). If you're not exercising, consider resting and monitoring. Consult a doctor if it persists.";
    return "Invalid heart rate detected. Please try again.";
  }

  Color getHeartRateColor(int? bpm) {
    if (bpm == null) return Colors.grey;
    if (bpm < 60) return Colors.blue;
    if (bpm >= 60 && bpm <= 100) return Colors.green;
    if (bpm > 100 && bpm <= 120) return Colors.orange;
    return Colors.red;
  }

  void _toggleMeasurement() {
    setState(() {
      isMeasuring = !isMeasuring;
      if (isMeasuring) {
        _initializeAnimationController();
      } else {
        _disposeAnimationController();
        bpmValue = null;
        data.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _disposeAnimationController();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Heart Rate Monitor',
            style: GoogleFonts.almarai(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeartAnimation(),
                  const SizedBox(height: 30),
                  _buildBpmDisplay(),
                  const SizedBox(height: 20),
                  _buildHeartRateDescription(),
                  const SizedBox(height: 20),
                  _buildDisclaimer(),
                  const SizedBox(height: 40),
                  _buildMeasurementButton(),
                  if (isMeasuring) _buildHeartRateMeasurement(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildHeartAnimation() {
    return AnimatedBuilder(
      animation: _animationController ?? const AlwaysStoppedAnimation(0),
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + ((_animationController?.value ?? 0) * 0.1),
          child: Lottie.asset(
            'assets/animated_icon/heart-rate-anim.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }

  Widget _buildBpmDisplay() {
    return Column(
      children: [
        Text(
          bpmValue?.toString() ?? "--",
          style: GoogleFonts.poppins(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: getHeartRateColor(bpmValue),
          ),
        ),
        Text(
          "BPM",
          style: GoogleFonts.poppins(
            fontSize: 24,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildHeartRateDescription() {
    return Text(
      getHeartRateDescription(bpmValue),
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        fontSize: 16,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Text(
      "Note: This measurement is for informational purposes only and should not be considered as medical advice. For accurate results, use medical-grade equipment.",
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        fontSize: 12,
        color: Colors.white54,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildMeasurementButton() {
    return ElevatedButton(
      onPressed: _toggleMeasurement,
      style: ElevatedButton.styleFrom(
        backgroundColor: isMeasuring ? Colors.red : Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        isMeasuring ? "Stop Measuring" : "Start Measuring",
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHeartRateMeasurement() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: HeartBPMDialog(
        context: context,
        onRawData: (value) {
          setState(() {
            if (data.length == 100) data.removeAt(0);
            data.add(value);
          });
        },
        onBPM: (value) => setState(() => bpmValue = value),
        child: Container(),
      ),
    );
  }
}