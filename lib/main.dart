import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:leaf_detector/pages/chatScreen.dart';

late List<CameraDescription> cameras;
Future<void> main() async {
  await Hive.initFlutter();
  var box = await Hive.openBox('mybox');
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leaf Detector',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
