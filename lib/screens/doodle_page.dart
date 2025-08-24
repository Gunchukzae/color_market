import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import 'doodle_utils.dart';

class DoodlePage extends StatefulWidget {
  final String imagePath;
  final void Function(String savedPath)? onSavedPath; // 저장된 파일 경로 콜백

  const DoodlePage({
    required this.imagePath,
    this.onSavedPath,
    super.key,
  });

  @override
  State<DoodlePage> createState() => _DoodlePageState();
}

class _DoodlePageState extends State<DoodlePage> {
  late SignatureController _controller;
  final GlobalKey _imageKey = GlobalKey();
  Size _originalImageSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(penStrokeWidth: 4, penColor: Colors.red);
    _loadOriginalImageSize();
  }

  Future<void> _loadOriginalImageSize() async {
    final byteData = await rootBundle.load(widget.imagePath);
    final decoded = img.decodeImage(byteData.buffer.asUint8List());
    if (decoded != null) {
      setState(() {
        _originalImageSize = Size(
          decoded.width.toDouble(),
          decoded.height.toDouble(),
        );
      });
    }
  }

  Future<void> _onSave() async {
    final rb = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (rb == null || _originalImageSize == Size.zero) return;

    final boxSize = rb.size;

    if (_controller.points.where((p) => p != null).length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ 낙서를 조금 더 해주세요')),
      );
      return;
    }

    final baseBytes = (await rootBundle.load(widget.imagePath)).buffer.asUint8List();
    final strokes = collectStrokes(_controller);
    final c = _controller.penColor;
    final penColor = img.ColorRgba8(c.red, c.green, c.blue, c.alpha);
    final dir = await getApplicationDocumentsDirectory();

    final savedPath = await drawStrokesOnOriginalAndSave(
      baseImageBytes: baseBytes,
      strokes: strokes,
      boxSize: ui.Size(boxSize.width, boxSize.height),
      originalSize: ui.Size(_originalImageSize.width, _originalImageSize.height),
      penColor: penColor,
      penStrokeWidth: _controller.penStrokeWidth,
      outputDirPath: dir.path,
    );

    _controller.clear();
    widget.onSavedPath?.call(savedPath);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ 저장됨: $savedPath')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = (_originalImageSize.width == 0 || _originalImageSize.height == 0)
        ? 1.0
        : _originalImageSize.width / _originalImageSize.height;

    return Scaffold(
      appBar: AppBar(title: const Text('낙서')),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: aspectRatio,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    widget.imagePath,
                    key: _imageKey,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned.fill(
                  child: Signature(
                    controller: _controller,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _onSave, child: const Text('저장')),
        ],
      ),
    );
  }
}
