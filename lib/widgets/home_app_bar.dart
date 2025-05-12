import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/page_provider.dart';
import '../providers/coin_provider.dart';
import '../providers/notification_provider.dart';
import '../constants/icons.dart';
import '../constants/keys.dart';

PreferredSizeWidget buildHomeAppBar(BuildContext context) {
  final pageProvider = context.watch<PageProvider>();

  return AppBar(
    leading: pageProvider.selectedPageIndex != -1
        ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => pageProvider.goHome(),
          )
        : null,
    title: Row(
      children: [
        const Text('Color Market'),
        const Spacer(),
        GestureDetector(
          key: bellKey,
          onTap: () {
            showDialog(
              context: context,
              builder: (_) {
                final notifications = context.read<NotificationProvider>().notifications;
                return buildNotificationDialog(context, notifications);
              },
            );
          },
          child: const RoundedButton(icon: AppIcons.bell),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(AppIcons.coin, color: Colors.grey, size: 20),
                const SizedBox(width: 5),
                Text('${context.watch<CoinProvider>().coins}p',
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        const RoundedButton(icon: AppIcons.gear),
      ],
    ),
  );
}

AlertDialog buildNotificationDialog(BuildContext context, List<RichText> notifications) {
  return AlertDialog(
    title: const Text('알림'),
    content: SizedBox(
      height: 150,
      width: 300,
      child: ListView(
        children: notifications.map((rich) {
          final textSpan = rich.text as TextSpan;
          final emojiSpan = textSpan.children?[0] as TextSpan?;
          final textSpan2 = textSpan.children?[1] as TextSpan?;

          final emoji = emojiSpan?.text ?? '❓';
          final emojiColor = emojiSpan?.style?.color ?? Colors.black;
          final text = textSpan2?.text ?? '';
          final textStyle = textSpan2?.style ?? const TextStyle(color: Colors.black);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                const Text('• ', style: TextStyle(color: Colors.black)),
                Text(emoji, style: TextStyle(fontSize: 24, color: emojiColor)),
                const SizedBox(width: 6),
                Text(text, style: textStyle),
              ],
            ),
          );
        }).toList(),
      ),
    ),
  );
}

class RoundedButton extends StatelessWidget {
  final IconData icon;
  const RoundedButton({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Icon(icon, color: Colors.grey, size: 20),
      ),
    );
  }
}