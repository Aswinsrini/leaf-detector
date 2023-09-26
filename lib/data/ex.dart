import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:excel/excel.dart';

class ExcelReader {
  Future<List<String>> readExcel(String sentence) async {
    List<String> res = [];
    try {
      final ByteData data = await rootBundle.load('assets/data1.xlsx');
      final List<int> bytes = data.buffer.asUint8List();
      final excel = Excel.decodeBytes(Uint8List.fromList(bytes));

      final sheet =
          excel.tables['Sheet1']!; // Assuming 'Sheet1' is your sheet name

      for (var row in sheet.rows) {
        final cellValueInColumn1 =
            row[0]?.toString() ?? ''; // Column 1 (index 0)
        final cellValueInColumn2 =
            row[1]?.toString() ?? ''; // Column 2 (index 1)
        final cellValueInColumn3 =
            row[2]?.toString() ?? ''; // Column 2 (index 1)
        final cellValueInColumn4 =
            row[3]?.toString() ?? ''; // Column 2 (index 1)
        final cellValueInColumn5 =
            row[4]?.toString() ?? ''; // Column 2 (index 1)

        final d1Text1 = cellValueInColumn1.split('0')[0].trim();
        final d1Text2 = d1Text1.replaceAll('Data(', '').trim();

        final d3Text1 = cellValueInColumn3.split('2,')[0].trim();
        final d3Text2 = d3Text1.replaceAll('Data(', '').trim();

        final d4Text1 = cellValueInColumn4.split('3,')[0].trim();
        final d4Text2 = d4Text1.replaceAll('Data(', '').trim();

        final d5Text1 = cellValueInColumn5.split('4,')[0].trim();
        final d5Text2 = d5Text1.replaceAll('Data(', '').trim();

        final d1Text3 = d1Text2.replaceAll(',', '').trim();
        final descriptionText = cellValueInColumn2.split('1,')[0].trim();
        final descriptionText1 = descriptionText.replaceAll('Data(', '').trim();
        RegExp wordPattern = RegExp(r'\b' + RegExp.escape(d1Text3) + r'\b',
            caseSensitive: false);

        // Check if the word is present in the sentence
        print(sentence + d1Text3);
        bool isWordPresent = wordPattern.hasMatch(sentence);

        if (isWordPresent) {
          // res.add(descriptionText1);
          res.add(d3Text2);
          res.add(d4Text2);
          res.add(d5Text2);
          return res;
        }
      }
      return ["It is not a medicinal plant"];

      // Handle case when input is not found
    } catch (e) {
      print('Error reading Excel: $e');
    }
    return ["Error"];
  }
}
