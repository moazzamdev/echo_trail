// path: services/navigation_service
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

class NavigationService {
  final FlutterTts tts = FlutterTts();

  Future<void> sendImageToBackend(File imageFile) async {
    final uri = Uri.parse("http://:8000/api/obstacle-detect/");

    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final message = responseData.contains("message")
          ? responseData.split('message":"')[1].split('"')[0]
          : "No message";

      print("🎤 $message");
      await tts.speak(message);
    } else {
      await tts.speak("Error detecting objects.");
    }
  }
}
