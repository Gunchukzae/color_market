import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart' show applyBoxFit, BoxFit, FittedSizes;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:signature/signature.dart';

/// controller 기반으로 스트로크 수집.
List<List<List<double>>> collectStrokes(SignatureController c) {
  final strokes = <List<List<double>>>[];
  final pts = c.points;
  if (pts.isEmpty) return strokes;

  var cur = <List<double>>[];

  for (int i = 0; i < pts.length; i++) {
    final p = pts[i];

    if (p.type != PointType.tap) { //tap 제외
      cur.add([p.offset.dx, p.offset.dy]);
    }

    final bool isLast = i == pts.length - 1;
    final bool nextIsTap = !isLast && pts[i + 1].type == PointType.tap;

    if (isLast || nextIsTap) {
      if (cur.isNotEmpty) {
        strokes.add(cur);
        cur = <List<double>>[];
      }
    }
  }
  return strokes;
}

/// strokes: [ [ [dx,dy], [dx,dy], ... ],   // 1st stroke
///          [ [dx,dy], ... ],             // 2nd stroke
///           ... ]
Future<String> drawStrokesOnOriginalAndSave({
  required Uint8List baseImageBytes,
  required List<List<List<double>>> strokes,
  required ui.Size boxSize,
  required ui.Size originalSize,
  required img.Color penColor,
  required double penStrokeWidth,
  required String outputDirPath,
  String? outputFileName,
}) async {
  final base = img.decodeImage(baseImageBytes);
  if (base == null) {
    throw Exception('base image decode failed');
  }

  final origW = base.width;
  final origH = base.height;

  final fs = applyBoxFit(
    BoxFit.contain,
    ui.Size(originalSize.width, originalSize.height),
    boxSize,
  );
  final renderW = fs.destination.width;
  final renderH = fs.destination.height;
  final dx = (boxSize.width - renderW) / 2.0;
  final dy = (boxSize.height - renderH) / 2.0;

  final sx = origW / renderW;
  final sy = origH / renderH;

  final thickness = math.max(1, (penStrokeWidth * math.min(sx, sy)).round());

  final canvas = img.Image.from(base);

  for (final stroke in strokes) {
    if (stroke.length < 2) {
      // 점 하나만 찍은 스트로크면 작은 원으로 찍어주기
      final pt = stroke.firstOrNull;
      if (pt != null) {
        final x = ((pt[0] - dx) * sx).round().clamp(0, origW - 1);
        final y = ((pt[1] - dy) * sy).round().clamp(0, origH - 1);
        img.drawCircle(canvas, x: x, y: y, radius: (thickness/2).ceil(), color: penColor);
      }
      continue;
    }
    for (int i = 1; i < stroke.length; i++) {
      final p0 = stroke[i - 1];
      final p1 = stroke[i];

      final x0 = ((p0[0] - dx) * sx);
      final y0 = ((p0[1] - dy) * sy);
      final x1 = ((p1[0] - dx) * sx);
      final y1 = ((p1[1] - dy) * sy);

      img.drawLine(
        canvas,
        x1: x0.round().clamp(0, origW - 1),
        y1: y0.round().clamp(0, origH - 1),
        x2: x1.round().clamp(0, origW - 1),
        y2: y1.round().clamp(0, origH - 1),
        color: penColor,
        thickness: thickness,
      );
    }
  }

  final outBytes = Uint8List.fromList(img.encodePng(canvas));
  final dir = Directory(outputDirPath);
  if (!await dir.exists()) await dir.create(recursive: true);

  final name = outputFileName ?? 'edit_${DateTime.now().millisecondsSinceEpoch}.png';
  final outPath = p.join(dir.path, name);
  await File(outPath).writeAsBytes(outBytes, flush: true);
  return outPath;
}
