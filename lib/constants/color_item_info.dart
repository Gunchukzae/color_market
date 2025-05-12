import 'package:flutter/material.dart';

class ColorInfo {
  final String symbol;
  final Color color;
  final String desc;
  final int price;

  const ColorInfo(this.symbol, this.color, this.desc, this.price);
}

const List<List<ColorInfo>> colorStyleGrid = [
  [
    ColorInfo('🍎', Colors.red, '사과', 5),
    ColorInfo('🍞', Colors.brown, '식빵', 4),
    ColorInfo('🥚', Colors.orange, '계란', 3),
    ColorInfo('🧀', Colors.amber, '치즈', 4),
  ],
  [
    ColorInfo('🍊', Colors.deepOrange, '오렌지', 5),
    ColorInfo('🥫', Colors.blueGrey, '통조림', 6),
    ColorInfo('🥟', Colors.pink, '만두', 3),
    ColorInfo('🍘', Colors.green, '쌀과자', 2),
  ],
  [
    ColorInfo('🍪', Colors.brown, '쿠키 한 조각', 4),
    ColorInfo('🍩', Colors.purple, '도넛', 5),
    ColorInfo('🥜', Colors.teal, '땅콩', 3),
    ColorInfo('🧈', Colors.yellow, '버터 한 덩이', 2),
  ],
  [
    ColorInfo('🍖', Colors.redAccent, '고기 뼈다귀', 7),
    ColorInfo('🥩', Colors.deepPurple, '스테이크 한 접시', 8),
    ColorInfo('🍗', Colors.orangeAccent, '닭다리', 6),
    ColorInfo('🥓', Colors.grey, '베이컨', 5),
  ],
  [
    ColorInfo('🥯', Colors.lime, '쫀득한 베이글', 3),
    ColorInfo('🧁', Colors.indigo, '컵케이크', 4),
    ColorInfo('🥠', Colors.cyan, '포춘쿠키', 3),
    ColorInfo('🍮', Colors.amberAccent, '푸딩', 5),
  ],
];