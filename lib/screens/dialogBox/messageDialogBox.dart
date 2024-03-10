import 'package:flutter/material.dart';

class messageDialogBox extends StatefulWidget {
  const messageDialogBox({super.key});

  @override
  State<messageDialogBox> createState() => _messageDialogBoxState();
}

class _messageDialogBoxState extends State<messageDialogBox> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AlertDialog(
        // title: const Text('Chat'),
        // content: const Text('AlertDialog description'),
        actions: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Chat",
                      style: TextStyle(fontSize: 20),
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close)),
                  ],
                ),
                Column(
                  children: const [
                    ListTile(
                      title: Text('Message 1'),
                    ),
                    ListTile(
                      title: Text('Message 2'),
                    ),
                    ListTile(
                      title: Text('Message 3'),
                    ),
                    ListTile(
                      title: Text('Message 4'),
                    ),
                    ListTile(
                      title: Text('Message 5'),
                    ),
                    ListTile(
                      title: Text('Message 6'),
                    ),
                    ListTile(
                      title: Text('Message 7'),
                    ),
                    ListTile(
                      title: Text('Message 8'),
                    ),
                    ListTile(
                      title: Text('Message 9'),
                    ),
                    ListTile(
                      title: Text('Message 10'),
                    ),
                    ListTile(
                      title: Text('Message 11'),
                    ),
                    ListTile(
                      title: Text('Message 12'),
                    ),
                    ListTile(
                      title: Text('Message 13'),
                    ),
                    ListTile(
                      title: Text('Message 14'),
                    ),
                    ListTile(
                      title: Text('Message 15'),
                    ),
                    ListTile(
                      title: Text('Message 16'),
                    ),
                    ListTile(
                      title: Text('Message 17'),
                    ),
                    ListTile(
                      title: Text('Message 18'),
                    ),
                    ListTile(
                      title: Text('Message 19'),
                    ),
                    ListTile(
                      title: Text('Message 20'),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: const TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Type your message here',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
