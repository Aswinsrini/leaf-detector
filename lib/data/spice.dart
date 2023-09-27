import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String> postImage_spice(File image) async {
  String output = "Not a medicinal Spice";
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.212.215:9000/predict'),
    );

    // Add the image file to the request
    print('bye0 ');
    request.files.add(await http.MultipartFile.fromPath('file', image.path));
    print('bye1 ');
    var response = await request.send();
    print('bye2 ');

    // Map<String, dynamic?> dataMap;
    if (response.statusCode == 200) {
      // Handle success
      String responseBody =
          await response.stream.transform(utf8.decoder).join();
      // Map<String, dynamic> dataMap = json.decode(responseBody);
      if (responseBody == "not") {
        return "Not a medicinal spice";
      }
      return responseBody;

      // output = dataMap["message"];
    } else {
      // Handle error
      print('Request failed with status: ${response.statusCode}');
    }
  } catch (e) {
    // Handle exceptions
    print('Error: $e');
  }
  return output;
}
