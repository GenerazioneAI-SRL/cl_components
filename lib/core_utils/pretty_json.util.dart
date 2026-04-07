import 'dart:convert';
import 'package:flutter/foundation.dart';

void printPrettyJson(Map<String, dynamic> json) {
  const encoder = JsonEncoder.withIndent('  ');
  debugPrint(encoder.convert(json));
}