import 'dart:convert';
import 'package:http/http.dart' as http;

class MagicCardApi {
  static Future<Map<String, dynamic>?> fetchCardData(String cardName) async {
    final url = Uri.parse('https://api.scryfall.com/cards/named?fuzzy=${Uri.encodeComponent(cardName)}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final String type = data['type_line'] ?? '';
      final String? power = data['power'];
      final String? toughness = data['toughness'];

      return {
        'type': type,
        'attack': power,
        'defense': toughness,
        'name': data['name'],
        'imageURL': data['image_uris']['normal'],
      };
    } else {
      return null;
    }
  }
}