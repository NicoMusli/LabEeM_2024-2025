import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class StorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/assets.json');
  }

  Future<Map<String, dynamic>> readJson() async {
    try {
      final file = await _localFile;

      if (!await file.exists()) {
        // Copy from assets if first time
        final data = await rootBundle.loadString('assets/assets.json');
        await file.writeAsString(data);
      }

      final contents = await file.readAsString();
      return json.decode(contents);
    } catch (e) {
      print("Read error: $e");
      return {};
    }
  }

  Future<void> writeJson(Map<String, dynamic> data) async {
    final file = await _localFile;
    await file.writeAsString(json.encode(data));
  }
}
