import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SP_Service {
  Future savePointer(int data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pointer', data);
  }

  Future saveAnsList(List<String> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('AnsList', data);
  }

  Future getPointer() async {
    final prefs = await SharedPreferences.getInstance();
    int? data = await prefs.getInt('pointer');
    return data;
  }

  Future getAnsList() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? data = prefs.getStringList('AnsList');
    return data;
  }

  Future clearPointer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pointer');
  }

  Future clearAnsList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('AnsList');
  }
}
