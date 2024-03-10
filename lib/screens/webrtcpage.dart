import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

class WebrtcPage extends StatefulWidget {
  const WebrtcPage({Key? key}) : super(key: key);

  @override
  _WebrtcPageState createState() => _WebrtcPageState();
}

class _WebrtcPageState extends State<WebrtcPage> {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  final _sdpController = TextEditingController();
  final _iceCandidateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initRenderers();
    initWebRTC();
  }

  Future<void> initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

Future<void> initWebRTC() async {
  final Map<String, dynamic> configuration = {
    "iceServers": [
      {"url": "stun:stun.l.google.com:19302"},
    ]
  };

  _peerConnection = await createPeerConnection(configuration, {});

  final status = await Permission.camera.request();
  final audioStatus = await Permission.microphone.request();

  if (status.isGranted && audioStatus.isGranted) {
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth': '640',
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    });

    _peerConnection!.addStream(_localStream!);
    _localRenderer.srcObject = _localStream;

    _peerConnection!.onIceCandidate = (candidate) {
      print('Got local ICE candidate: ${candidate.toMap()}');
        };

    _peerConnection!.onTrack = (event) {
      if (event.track.kind == 'video') {
        _remoteRenderer.srcObject = event.streams[0];
      }
    };
  } else {
    print('Permissions are not granted');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebRTC Demo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: RTCVideoView(_localRenderer),
          ),
          Expanded(
            child: RTCVideoView(_remoteRenderer),
          ),
          TextField(
            controller: _sdpController,
            decoration: const InputDecoration(
              labelText: 'Enter remote SDP',
            ),
          ),
          TextField(
            controller: _iceCandidateController,
            decoration: const InputDecoration(
              labelText: 'Enter remote ICE candidate',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _peerConnection!.setRemoteDescription(
                RTCSessionDescription(
                  _sdpController.text,
                  'offer',
                ),
              );
              await _peerConnection!.addCandidate(
                RTCIceCandidate(
                  _iceCandidateController.text,
                  '',
                  0,
                ),
              );
            },
            child: const Text('Start Call'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection!.dispose();
    super.dispose();
  }
}
