// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, camel_case_types, use_build_context_synchronously

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_video_call/screens/videocallPage.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;

class homePage extends StatefulWidget {
  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  bool isError = false;
  String errorMsg = '';
  String meetingCode = '';
  bool isLoading = false;
  TextEditingController meetingCodeController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  void generateMeetingCode() {
    // Add your logic to generate meeting code here
    const chars = "abcdefghijklmnopqrstuvwxyz0123456789";

    Random rnd = new Random();
    String result = "";
    for (var i = 0; i < 10; i++) {
      result += chars[rnd.nextInt(chars.length)];
    }
    setState(() {
      meetingCode = result;
    });
    // return codeDigits.join();
  }

  Future<void> sendAnswerAndIceCandidate(
      String meetingCode, String answerSdp, String iceCandidate) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.4/videocall/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'meeting_code': meetingCode,
        'answer_sdp': answerSdp,
        'user2_ice_candidates': iceCandidate,
      }),
    );
    if (response.statusCode==200){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallScreen(
            // meetingCode: meetingCode,
            // username: usernameController.text,
          ),
        ),
      );
    }
    else{
      setState(() {
        isError = true;
        isLoading = false;
        errorMsg = "Error: ${response.statusCode}";
      });
    }
  }

  Future<void> sendOfferAndIceCandidate(
      String meetingCode, String offerSdp, String iceCandidate) async {
    print("❌ " + meetingCode + " " + offerSdp + " " + iceCandidate);
    final response = await http.post(
      Uri.parse('http://192.168.1.4/videocall/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'meeting_code': meetingCode,
        'offer_sdp': offerSdp,
        'user1_ice_candidates': iceCandidate,
        'user1name': 'YourUserName', // replace with actual user name
      }),
    );
    if (response.statusCode==201){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallScreen(
            // meetingCode: meetingCode,
            // username: usernameController.text,
          ),
        ),
      );
    }
    else{
      setState(() {
        isError = true;
        isLoading = false;
        errorMsg = "Error: ${response.statusCode}";
      });
    }
  }

  Future<String?> createOfferSdp() async {
    // Create RTCPeerConnection
    Map<String, dynamic> configuration = {
      "iceServers": [
        {"url": "stun:stun.l.google.com:19302"},
      ]
    };
    RTCPeerConnection pc = await createPeerConnection(configuration, {});
    // Create offer
    RTCSessionDescription offer = await pc.createOffer({});
    // Set local description
    await pc.setLocalDescription(offer);
    // Return offer SDP
    return offer.sdp;
  }

  Future<List<RTCIceCandidate>> gatherIceCandidates() async {
    // Create RTCPeerConnection
    Map<String, dynamic> configuration = {
      "iceServers": [
        {"url": "stun:stun.l.google.com:19302"},
      ]
    };
    RTCPeerConnection pc = await createPeerConnection(configuration, {});
    // Create offer
    RTCSessionDescription offer = await pc.createOffer({});
    // Set local description
    await pc.setLocalDescription(offer);
    // Gather ICE candidates
    List<RTCIceCandidate> iceCandidates = [];
    pc.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate != null) {
        iceCandidates.add(candidate);
      }
    };
    // Wait for ICE gathering to complete
    await Future.delayed(Duration(seconds: 5));
    // Return ICE candidates
    return iceCandidates;
  }

  Future<String?> createAnswerSdp(String offerSdp) async {
    // Create RTCPeerConnection
    Map<String, dynamic> configuration = {
      "iceServers": [
        {"url": "stun:stun.l.google.com:19302"},
      ]
    };
    RTCPeerConnection pc = await createPeerConnection(configuration, {});
    // Set remote description
    RTCSessionDescription offer = RTCSessionDescription(offerSdp, 'offer');
    await pc.setRemoteDescription(offer);
    // Create answer
    RTCSessionDescription answer = await pc.createAnswer({});
    // Set local description
    await pc.setLocalDescription(answer);
    // Return answer SDP
    return answer.sdp;
  }

  Future<void> sendPostRequest() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.4/videocall/$meetingCode'),
      headers: {"Content-Type": "application/json"},
    );
    print("❌ " + response.statusCode.toString());
    if (response.statusCode == 200) {
      // Get offer_sdp from response
      String offerSdp = jsonDecode(response.body)['offer_sdp'];

      // Generate answer_sdp
      String? answerSdp = await createAnswerSdp(offerSdp);

      // Gather user2_ice_candidate
      List<RTCIceCandidate> iceCandidates = await gatherIceCandidates();

      // Send answer_sdp and user2_ice_candidate
      await sendAnswerAndIceCandidate(meetingCode, answerSdp!, iceCandidates as String);
    } else if (response.statusCode == 404) {
      // Generate user1_ice_candidate
      List<RTCIceCandidate> iceCandidates = await gatherIceCandidates();

      // Generate offer_sdp
      String? offerSdp = await createOfferSdp();

      // Send offer_sdp and user1_ice_candidate
      await sendOfferAndIceCandidate(meetingCode, offerSdp!, iceCandidates as String);
    }
    else{
      setState(() {
        isError = true;
        isLoading = false;
        errorMsg = "Error: ${response.statusCode}";
      });
    }
  }

  void startVideoCall() {
    setState(() {
      isLoading = true;
    });
    // add code to send meeting code to server on api https://myvideocall-api.onrender.com/
    String username = usernameController.text;
    // String newmeetingCode = meetingCodeController.text;
    // print("New Meeting Code:$meetingCode ");
    // print(newmeetingCode.length);

    if (username.isEmpty) {
      setState(() {
        isError = true;
        isLoading = false;
        errorMsg = "Username is empty, please enter a user name.";
      });
      return;
    }
    // else if (meetingCode.isEmpty) {
    //   setState(() {
    //     isError = true;
    //     isLoading = false;
    //     errorMsg =
    //         "Meeting code is empty, please generate or enter a meeting code.";
    //     meetingCode = '';
    //   });
    // return;
    // }
    else {
      sendPostRequest();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.grey[900],
            statusBarIconBrightness: Brightness.light,
          ),
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          height: 480,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey[700],
            boxShadow: const [
              BoxShadow(color: Colors.grey, blurRadius: 1, spreadRadius: 1)
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Image(
                  image: AssetImage('assets/icons/videocall.png'),
                  height: 100,
                  width: 100,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: usernameController,
                  style: const TextStyle(color: Colors.white70),
                  keyboardType: TextInputType.text,
                  cursorColor: Colors.white70,
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(color: Colors.white70),
                    labelText: 'User Name',
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Enter your name',
                    hintStyle: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  style: const TextStyle(color: Colors.white70),
                  keyboardType: TextInputType.text,
                  cursorColor: Colors.white70,
                  controller: TextEditingController(text: meetingCode),
                  readOnly: false,
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(color: Colors.white70),
                    labelText: 'Meeting Code',
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // fillColor: Colors.white70,
                    // focusColor: Colors.white70,
                    border: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),

                    // fillColor: Colors.white,
                    hintText: 'Enter or Generate Code',
                    hintStyle: const TextStyle(color: Colors.white),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.copy,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: meetingCode));
                      },
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 100),
                  child: TextButton(
                    // style: ButtonStyle(
                    //   minimumSize: MaterialStateProperty.all(const Size(200, 50)),
                    //   shadowColor: MaterialStateProperty.all(Colors.grey),
                    //   elevation: MaterialStateProperty.all(5),
                    //   backgroundColor: MaterialStateProperty.all(Colors.white),

                    // ),
                    onPressed: generateMeetingCode,

                    child: const Text(
                      'Generate New Code',
                      style: TextStyle(fontSize: 13, color: Colors.white70),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                isError
                    ? Text(errorMsg.toString(),
                        style: const TextStyle(color: Colors.red, fontSize: 15),
                        textAlign: TextAlign.center)
                    : const SizedBox(
                        height: 5,
                      ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ButtonStyle(
                    maximumSize: MaterialStateProperty.all(const Size(200, 50)),
                    minimumSize: MaterialStateProperty.all(const Size(90, 50)),
                    shadowColor: MaterialStateProperty.all(Colors.grey),
                    elevation: MaterialStateProperty.all(5),
                    backgroundColor: MaterialStateProperty.all(
                        const Color.fromARGB(255, 57, 57, 57)),
                  ),
                  onPressed: () => startVideoCall(),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_call,
                                size: 30, color: Colors.white70),
                            SizedBox(width: 5),
                            Text('Start Call',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white)),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
