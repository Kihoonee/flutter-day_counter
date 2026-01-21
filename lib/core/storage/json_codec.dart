// lib/core/storage/json_codec.dart
import 'dart:convert';

String encodeList(List<Map<String, dynamic>> list) => jsonEncode(list);
List<dynamic> decodeList(String raw) => jsonDecode(raw) as List<dynamic>;
