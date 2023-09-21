import 'dart:io';
import "package:image_picker/image_picker.dart";
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];
  File? image; // Declare it at the class level
  File? _imageFile; // Store the selected image file
  int current_Index = 0;
  File? galleryFile;
  bool isMore = false;
  final picker = ImagePicker();

  void onTabTapped(int index) {
    setState(() {
      current_Index = index;
      if (index == 1) {
        isMore = true;
      } else {
        isMore = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
// Add this line

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plantidex'),
        elevation: 5,
        centerTitle: true,
      ),
      body: isMore
          ? const Column(
              children: [
                Center(
                  child: Text('More Page'),
                ),
              ],
            )
          : Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _messages[index];
                    },
                  ),
                ),
                // Divider(height: 1.0),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(35.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _messageController,
                            onChanged: (text) {
                              // You can handle text input changes here
                            },
                            decoration: const InputDecoration(
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              hintText: 'Ask something...',
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 15.0),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                            Icons.attach_file), // Add an attachment icon
                        onPressed: () {
                          _showPicker(
                              context:
                                  context); // Launch image picker when the icon is tapped
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
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
        elevation: 9,
      ),
    );
  }

  void _handleSubmittedMessage(String text, File? imageFile) {
    if (text.isEmpty && imageFile == null) {
      return;
    }

    ChatMessage message = ChatMessage(
      text: text,
      isUser: true,
      imageFile: galleryFile,
    );

    setState(() {
      _messages.add(message);
    });

    _messageController.clear();
    setState(() {
      galleryFile = null;
      _imageFile = null; // Clear the selected image file
    });
  }

  void _showPicker({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future getImage(
    ImageSource img,
  ) async {
    final pickedFile = await picker.pickImage(source: img);
    XFile? xfilePick = pickedFile;
    setState(
      () {
        if (xfilePick != null) {
          galleryFile = File(pickedFile!.path);
          fileAdded();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(// is this context <<<
              const SnackBar(content: Text('Nothing is selected')));
        }
      },
    );
  }

  void fileAdded() {
    ChatMessage message = ChatMessage(
      text: '',
      isUser: true,
      imageFile: galleryFile,
    );

    setState(() {
      _messages.add(message);
    });
    setState(() {
      galleryFile = null;
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
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          if (imageFile != null)
            Image.file(
              imageFile!,
              width: 200.0,
              height: 200.0,
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
                style: const TextStyle(
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
