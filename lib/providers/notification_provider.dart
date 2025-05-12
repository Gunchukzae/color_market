import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  final List<RichText> _notifications = [];

  List<RichText> get notifications => _notifications;

  void add(RichText message) {
    _notifications.insert(0, message);
    notifyListeners();
  }
}