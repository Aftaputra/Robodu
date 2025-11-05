import 'package:flutter/material.dart';
import 'package:robodu/utils/helper.dart';
import 'package:robodu/utils/strings.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF4CB6B6);
    const Color cardColor = Color(0xFFE8F7F7);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                StatusText.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      StatusText.subTitleSensor,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: mainColor, size: 20),
                        SizedBox(width: 6),
                        Text(StatusText.sensorCameraStatus),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: mainColor, size: 20),
                        SizedBox(width: 6),
                        Text(StatusText.sensorEnoseStatus),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ENose Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      StatusText.subTitleEnose,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      StatusText.enoseSensorResult,
                      style: TextStyle(
                        color: mainColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Log Aktivitas
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      StatusText.subTitleLog,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // TODO: change time value based on data from robot
                    _LogItem(title: StatusText.logMoveForward, time: AppHelper.getFormattedDate(DateTime.now(), format: 'HH:mm')),
                    _LogItem(title: StatusText.logMoveStop, time: AppHelper.getFormattedDate(DateTime.now(), format: 'HH:mm')),
                    _LogItem(title: StatusText.logTurnRight, time: AppHelper.getFormattedDate(DateTime.now(), format: 'HH:mm')),
                    _LogItem(title: StatusText.logTurnLeft, time: AppHelper.getFormattedDate(DateTime.now(), format: 'HH:mm')),
                    _LogItem(title: StatusText.logRightHandMove, time: AppHelper.getFormattedDate(DateTime.now(), format: 'HH:mm')),
                    _LogItem(title: StatusText.logLeftHandMove, time: AppHelper.getFormattedDate(DateTime.now(), format: 'HH:mm')),
                    _LogItem(title: StatusText.logSpeakRobodu, time: AppHelper.getFormattedDate(DateTime.now(), format: 'HH:mm')),
                    _LogItem(title: StatusText.logIntroduceSelf, time: AppHelper.getFormattedDate(DateTime.now(), format: 'HH:mm')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogItem extends StatelessWidget {
  final String title;
  final String time;

  const _LogItem({required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            time,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
