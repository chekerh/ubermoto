import 'package:flutter/material.dart';

void main() {
  print('All TextDirection values:');
  for (var value in TextDirection.values) {
    print('  $value');
  }
  
  print('\nTesting access:');
  try {
    print('TextDirection.rtl: ${TextDirection.rtl}');
  } catch (e) {
    print('Error accessing rtl: $e');
  }
  
  try {
    print('TextDirection.ltr: ${TextDirection.ltr}');
  } catch (e) {
    print('Error accessing ltr: $e');
  }
  
  try {
    print('TextDirection.RTL: ${TextDirection.RTL}');
  } catch (e) {
    print('Error accessing RTL: $e');
  }
  
  try {
    print('TextDirection.LTR: ${TextDirection.LTR}');
  } catch (e) {
    print('Error accessing LTR: $e');
  }
}
