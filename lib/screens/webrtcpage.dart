import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:sdp_transform/sdp_transform.dart';

class VideoCallPage extends StatefulWidget {
  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  late RTCPeerConnection _peerConnection;
  late MediaStream _localStream;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

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
    // Fetch device details from API
    var response = await http.get('https://myvideocall-api.onrender.com/videocall/' as Uri);
    var data = jsonDecode(response.body);

    // Initialize the local stream
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth': '640', // Provide your own width, height and frame rate here
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    _localRenderer.srcObject = _localStream;

    // Initialize the connection
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'url': 'stun:stun.l.google.com:19302'},
      ]
    });

    _peerConnection.onIceCandidate = (candidate) {
      if (candidate == null) {
        print('onIceCandidate: complete!');
      }
    };

    _peerConnection.onAddStream = (stream) {
      print('addStream: ' + stream.id);
      _remoteRenderer.srcObject = stream;
    };

    // Add the stream to the connection
    _peerConnection.addStream(_localStream);

    // Create an offer
    RTCSessionDescription description = await _peerConnection.createOffer({
      'offerToReceiveAudio': 1,
      'offerToReceiveVideo': 1
    });

    var session = parse(description.sdp!);
    print(json.encode(session));

    // Set the description
    await _peerConnection.setLocalDescription(description);

    // Send the offer to the other peer using the API
    await http.post('https://myvideocall-api.onrender.com/videocall/' as Uri, body: {
      'sdp': description.sdp,
      'type': description.type,
      'meeting_code': data['meeting_code'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Call'),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Row(
            children: <Widget>[
              Flexible(
                child: RTCVideoView(_localRenderer),
              ),
              Flexible(
                child: RTCVideoView(_remoteRenderer),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection.close();
    super.dispose();
  }
}