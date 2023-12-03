import 'dart:io';
import "package:image_picker/image_picker.dart";
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:leaf_detector/data/database.dart';
import 'package:leaf_detector/data/ex.dart';
import 'package:leaf_detector/data/spice.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _myBox = Hive.box("mybox");
  ChatDataBase db = ChatDataBase();

  ScrollController _scrollController = new ScrollController();
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];
  File? image; // Declare it at the class level
  File? _imageFile; // Store the selected image file
  int current_Index = 0;
  File? galleryFile;
  bool isMore = false;
  String output = "";
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
  void initState() {
    if (_myBox.get('chat_hist') == null) {
      db.createInitialData();
    } else {
      db.loadData();
    }

    super.initState();
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
          ? Container(
              margin: EdgeInsets.all(14),
              child: Column(
                children: [
                  const Center(
                    child: Text(
                        "More about this application:\nThis application is an AI-powered tool designed to identify and provide information about different types of leaves. you can simply upload leaf images, and the chatbot utilizes machine learning algorithms to classify them, often offering details about the plant species and care instructions. It's a valuable resource for nature enthusiasts, gardeners, and researchers, aiding in plant identification and fostering environmental awareness. With continuous improvements in accuracy and expanding botanical databases, leaf detection chatbots are becoming increasingly reliable and informative. They play a crucial role in promoting biodiversity knowledge and sustainable plant management."),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      exit(0);
                    },
                    child: const Text(
                      'Exit',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    // reverse: true,
                    controller: _scrollController,
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
                            maxLines: null,
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
                          setState(() {
                            output = _messageController.text;
                          });
                          _handleSubmittedMessage(
                              _messageController.text, _imageFile);
                          outputFromBot(output);
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

  void _handleSubmittedMessage(String text, File? imageFile) async {
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
      saveNewTask(message);
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

  void fileAdded() async {
    // String bot1 = await postImage(galleryFile!);
    String bot2 = await postImage_spice(galleryFile!);
    // print(bot1 + " from bot1");
    // bot1 = "The Image you provided is " + bot1;
    bot2 = "The Image you provided is " + bot2;
    ChatMessage message = ChatMessage(
      text: '',
      isUser: true,
      imageFile: galleryFile,
    );
    // ChatMessage m1 = ChatMessage(
    //   text: bot1,
    //   isUser: false,
    //   imageFile: null,
    // );
    ChatMessage m2 = ChatMessage(
      text: bot2,
      isUser: false,
      imageFile: null,
    );

    setState(() {
      _messages.add(message);
      // _messages.add(m1);
      _messages.add(m2);
      // saveNewTask(message);
    });
    setState(() {
      galleryFile = null;
      _imageFile = null; // Clear the selected image file
    });
  }

  void saveNewTask(ChatMessage msg) {
    setState(() {
      db.chat_hist.add(msg);
    });
  }

  void outputFromBot(String sentence) async {
    List<String> msg = await ExcelReader().readExcel(sentence);
    for (String m1 in msg) {
      ChatMessage message = ChatMessage(
        text: m1,
        isUser: false,
        imageFile: galleryFile,
      );
      setState(() {
        _messages.add(message);
        saveNewTask(message);
      });
    }
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
            ConstrainedBox(
              constraints: const BoxConstraints(
                  maxWidth: 300.0), // Set the maximum width
              child: Container(
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
                  maxLines: null, // Allow unlimited lines
                ),
              ),
            )
        ],
      ),
    );
  }
}
