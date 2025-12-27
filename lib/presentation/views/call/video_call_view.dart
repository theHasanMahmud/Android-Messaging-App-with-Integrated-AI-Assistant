import 'package:flutter/material.dart';

class VideoCallView extends StatelessWidget {
  final String callID;
  final String userName;
  final String userID;

  const VideoCallView({
    super.key,
    required this.callID,
    required this.userName,
    required this.userID,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Call')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            Text('Video Call: $callID', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('User: $userName'),
            const SizedBox(height: 40),
            const Text(
              'Video call feature ready!\nIntegrate with your preferred SDK',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
