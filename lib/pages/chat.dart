import 'dart:io';
import "package:image_picker/image_picker.dart";
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];
  File? _imageFile; // Store the selected image file
  int current_Index = 0;

  void onTabTapped(int index) {
    setState(() {
      current_Index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
// Add this line

    return Scaffold(
      appBar: AppBar(
        title: Text('Plantidex'),
        elevation: 1,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),
          Divider(height: 1.0),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onChanged: (text) {
                      // You can handle text input changes here
                    },
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.attach_file), // Add an attachment icon
                  onPressed: () {
                    _getImage(); // Launch image picker when the icon is tapped
                  },
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _handleSubmittedMessage(
                        _messageController.text, _imageFile);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_outlined),
            label: ('Scan'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_rounded),
            label: ('Chat'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_vert),
            label: ('More'),
          ),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: current_Index,
        selectedItemColor: Colors.green,
        iconSize: 30,
        selectedFontSize: 16,
        onTap: onTabTapped,
        elevation: 5,
      ),
    );
  }

  File? image; // Declare it at the class level

  Future<void> _getImage() async {
    var status = await Permission.photos.request();
    if (status.isGranted) {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage == null) return;
      final imageTemp = File(pickedImage.path);
      setState(() {
        image = imageTemp;
      });
    }
  }

  void _handleSubmittedMessage(String text, File? imageFile) {
    if (text.isEmpty && imageFile == null) {
      return;
    }

    ChatMessage message = ChatMessage(
      text: text,
      isUser: true,
      imageFile: image,
    );

    setState(() {
      _messages.add(message);
    });

    _messageController.clear();
    setState(() {
      _imageFile = null; // Clear the selected image file
    });
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final File? imageFile;

  ChatMessage(
      {required this.text, required this.isUser, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          if (imageFile != null)
            Image.file(
              imageFile!,
              width: 100.0,
              height: 100.0,
              fit: BoxFit.cover,
            ),
          if (imageFile == null)
            Container(
              decoration: BoxDecoration(
                color: isUser ? Colors.blue : Colors.grey,
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.all(10.0),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
