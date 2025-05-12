import 'package:flutter/material.dart';

void showBellNotification(BuildContext context, RichText message, GlobalKey key) {
  final overlay = Overlay.of(context);
  final renderBox = key.currentContext!.findRenderObject() as RenderBox;
  final position = renderBox.localToGlobal(Offset.zero);

  final entry = OverlayEntry(
    builder: (_) => Positioned(
      top: position.dy + renderBox.size.height + 8,
      left: position.dx,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(8),
          ),
          child: message
        ),
      ),
    ),
  );

  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 2), () => entry.remove());
}

RichText buildNotificationText({
  required String emoji,
  required String message,
  required Color symbolColor,
  required Color textColor,
}) {
  return RichText(
    text: TextSpan(
      style: TextStyle(fontSize: 18, color: textColor),
      children: [
        TextSpan(
          text: emoji,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: symbolColor,
          ),
        ),
        TextSpan(text: message),
      ],
    ),
  );
}
