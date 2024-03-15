import 'package:flutter/material.dart';
import 'package:flutter_video_call/screens/home.dart';
// import 'package:flutter_video_call/screens/home.dart';
// import 'package:flutter_video_call/screens/webrtcpage.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
  checkPermissions();
}

void checkPermissions() async {
  var cameraStatus = await Permission.camera.status;
  var microphoneStatus = await Permission.microphone.status;

  if (!cameraStatus.isGranted) {
    await Permission.camera.request();
  }

  if (!microphoneStatus.isGranted) {
    await Permission.microphone.request();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'my meet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent, secondary: Colors.blueAccent, primary: Colors.blueAccent),
        useMaterial3: true,
      ),
      home:homePage(),
      // WebrtcPage() 
      
    );
  }
}
