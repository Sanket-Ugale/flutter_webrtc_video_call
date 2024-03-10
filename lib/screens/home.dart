// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, camel_case_types, use_build_context_synchronously

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_video_call/screens/videocallPage.dart';
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

  Future<void> sendPostRequest() async {
    String username = usernameController.text;
    // String meeting_code = meetingCodeController.text;
    var url = Uri.parse('https://myvideocall-api.onrender.com/videocall/');
    var body = jsonEncode({'user1name': username, 'meeting_code': meetingCode});

    var response = await http
        .post(url, body: body, headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
            setState(() {
        isLoading=false;
      });
      // If server returns an OK response, navigate to VideoCallPage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VideoCallScreen()),
      );
    } else if (response.statusCode == 201) {
      // If server returns an OK response, navigate to VideoCallPage
            setState(() {
        isLoading=false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VideoCallScreen()),
      );
    } else {

      // If response was not OK, set the error message
      setState(() {
        isLoading=false;
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
        isLoading=false;
        errorMsg = "Username is empty, please enter a user name.";
      });
      return;
    }
    // print("Meeting Code:$meetingCode ");
    // print(meetingCode.length);
    else if (meetingCode.isEmpty) {
      setState(() {
        isError = true;
        isLoading=false;
        errorMsg =
            "Meeting code is empty, please generate or enter a meeting code.";
        meetingCode = '';
      });
      return;
    }
    // else if (meetingCode != 10) {
    //   setState(() {
    //     isError = true;
    //     errorMsg =
    //         "Meeting code is invalid, please generate or enter a valid meeting code.";
    //   });
    //   return;
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
                // SizedBox(height: 20,),
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
