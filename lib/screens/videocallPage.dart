import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_video_call/screens/dialogBox/messageDialogBox.dart';

    import 'package:audioplayers/audioplayers.dart';

class VideoCallScreen extends StatefulWidget {
  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool micMuted = false;
  bool cameraOff = false;
  Offset offset = const Offset(50, 50); // initial position
  CameraController? controller;
  CameraDescription? cameraDescription;
  AudioPlayer? audioPlayer;
  @override
  void initState() {
    super.initState();
    initCamera();
    initMic();
  }


  Future<void> initMic() async {
    audioPlayer = AudioPlayer();
    setState(() {
      
    });
  }

  Future<void> controlMic() async {
    if (micMuted && audioPlayer != null) {
      await audioPlayer!.stop();
    } else if (!micMuted && audioPlayer == null) {
      await initMic();
    }
  }

  Widget userMicContainer() {
    if (micMuted == true) {
      return const Center(child: Text('Mic is off', style: TextStyle(color: Colors.white),));
    } else if (audioPlayer == null) {
      return const Center(child: Text('Loading...', style: TextStyle(color: Colors.white),));
    } else {
      return const Center(child: Text('Mic is on', style: TextStyle(color: Colors.white),));
    }
  }
  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);
    controller = CameraController(frontCamera, ResolutionPreset.medium);
    await controller!.initialize();
    setState(() {
      
    });
  }

  Future<void> controlCamera() async {
    if (cameraOff && controller != null) {
      await controller!.dispose();
      controller = null;
    } else if (!cameraOff && controller == null) {
      await initCamera();
    }
  }

  Widget userCameraContainer() {
    if (cameraOff == true) {
      return Container(
          width: 100.0,
          height: 150.0,
          decoration: BoxDecoration(
            color: Colors.grey,
            border: Border.all(color: Colors.white, width: 2.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Container(
              width: 100.0,
              height: 150.0,
              decoration: BoxDecoration(
                color: Colors.grey,
                border: Border.all(color: Colors.white, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Center(
                  child: Text(
                'Camera is off',
                style: TextStyle(color: Colors.white),
              ))));
    } else if (controller == null || !controller!.value.isInitialized) {
      return const Center(
          child: Text(
        'Loading...',
        style: TextStyle(color: Colors.white),
      ));
    } else {
      return Container(
        width: 100.0,
        height: 150.0,
        decoration: BoxDecoration(
          color: Colors.grey,
          border: Border.all(color: Colors.white, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: CameraPreview(controller!),
        ),
      );
    }
  }



  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.grey[900],
            statusBarIconBrightness: Brightness.light,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              color: Colors.grey[900],
              child: const Center(
                child: Text(
                  'Video Call View',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Positioned(
              left: offset.dx,
              top: offset.dy,
              child: Draggable(
                child: userCameraContainer(),
                feedback: userCameraContainer(),
                childWhenDragging: Container(),
                onDraggableCanceled: (velocity, offset) {
                  setState(() {
                    this.offset = offset;
                  });
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      icon: micMuted
                          ? const Icon(Icons.mic_off)
                          : const Icon(Icons.mic),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.grey[200]),
                        shadowColor: MaterialStateProperty.all(
                          Colors.grey,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          micMuted = !micMuted;
                        });
                        // Add your logic to mute/unmute mic here
                      },
                    ),
                    IconButton(
                      icon: cameraOff
                          ? const Icon(
                              Icons.videocam_off,
                            )
                          : const Icon(
                              Icons.videocam,
                              color: Color.fromARGB(255, 0, 166, 255),
                            ),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.grey[200]),
                        shadowColor: MaterialStateProperty.all(
                          Colors.grey,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          cameraOff = !cameraOff;
                        });
                        // Add your logic to turn on/off camera here
                      },
                    ),
                    IconButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.grey[100]),
                        shadowColor: MaterialStateProperty.all(
                          Colors.grey,
                        ),
                      ),
                      icon: const Icon(
                        Icons.call_end,
                        size: 40,
                      ),
                      color: Colors.red,
                      onPressed: () {
                        Navigator.pop(context);
                        // Add your logic to end call here
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.grey[200]),
                        shadowColor: MaterialStateProperty.all(
                          Colors.grey,
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const messageDialogBox(),
                        );
                        // Add your logic to open chat here
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.grey[200]),
                        shadowColor: MaterialStateProperty.all(
                          Colors.grey,
                        ),
                      ),
                      onPressed: () {
                        // Add your logic to open settings here
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Assuming these variables are defined somewhere in your code

// Future<void> controlCamera() async {
//   if (cameraOff && controller != null) {
//     await controller!.dispose();
//     controller = null;
//   } else if (!cameraOff && controller == null && cameraDescription != null) {
//     controller = CameraController(
//       cameraDescription!,
//       ResolutionPreset.medium,
//     );
//     await controller!.initialize();
//   }
// }

// Widget userCameraContainer() {
//   return FutureBuilder(
//     future: controlCamera(),
//     builder: (context, snapshot) {
//       if (snapshot.connectionState == ConnectionState.waiting) {
//         return Center(child: Text('Loading...', style: TextStyle(color: Colors.white),));
//       } else {
//         return Container(
//           width: 100.0,
//           height: 150.0,
//           decoration: BoxDecoration(
//             color: Colors.grey,
//             border: Border.all(color: Colors.white, width: 2.0),
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//           child:
//           (cameraOff == true) ? const Center(child: Text('Camera is off', style: TextStyle(color: Colors.white),)) :
//           (controller == null || !controller!.value.isInitialized) ? const Center(child: Text('Loading...', style: TextStyle(color: Colors.white),)) : AspectRatio(
//             aspectRatio: controller!.value.aspectRatio,
//             child: CameraPreview(controller!),
//           ),
//         );
//       }
//     },
//   );
// }
}
