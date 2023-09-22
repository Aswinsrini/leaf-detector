import 'package:hive_flutter/hive_flutter.dart';

class ChatDataBase {
  List chat_hist = [];

  final _myBox = Hive.box("mybox");
  void createInitialData() {
    chat_hist = ["How can I assist you Today!!"];
  }

  void loadData() {
    chat_hist = _myBox.get("chat_hist");
  }

  void updateDataBase() {
    _myBox.put("chat_hist", chat_hist);
  }
}
