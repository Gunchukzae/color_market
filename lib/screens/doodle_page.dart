import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'doodle_utils.dart';

class DoodlePage extends StatefulWidget {
  final String imagePath;
  final void Function(String savedPath)? onSavedPath;

  const DoodlePage({
    required this.imagePath,
    this.onSavedPath,
    super.key,
  });

  @override
  State<DoodlePage> createState() => _DoodlePageState();
}

class _StrokeLayer {
  final int id;
  final SignatureController controller;
  final Color color;
  _StrokeLayer(this.id, this.controller, this.color);
}

class _HistoryEntry {
  final int layerId;
  _HistoryEntry({required this.layerId});
}

class _DoodlePageState extends State<DoodlePage> {
  final List<_StrokeLayer> _layers = [];        // id,ctrl,penColor를 _StrokeLayer에 보관
  final List<_HistoryEntry> _history = [];      // 전역 undo 스택
  final List<_HistoryEntry> _redoHistory = [];  // 전역 redo 스택
  int _layerSeq = 0;

  SignatureController get _controller => _layers.last.controller;
  Color get _penColor => _layers.last.color;

  final GlobalKey _imageKey = GlobalKey();
  Size _originalImageSize = Size.zero;

  final Color _canvasBg = const Color(0xFFF3F4F6);
  bool _eraserOn = false;

  @override
  void initState() {
    super.initState();
    _addNewLayer(Colors.red);
    _loadOriginalImageSize();
  }

  void _addNewLayer(Color color) {
    final id = _layerSeq++;
    late SignatureController ctrl;

    ctrl = SignatureController(
      penColor: color,
      penStrokeWidth: 4,
      strokeCap: StrokeCap.round,
      strokeJoin: StrokeJoin.round,
      exportBackgroundColor: Colors.transparent,
      onDrawStart: () {
      _history.add(_HistoryEntry(layerId: id));
      _redoHistory.clear();
      },
    );
    _layers.add(_StrokeLayer(id, ctrl, color));
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

  // 색 변경 시: 새 SignatureController(id, ctrl, penColor) 추가 (기존 레이어는 유지)
  void _applyPenColor(Color newColor) {
    if (_penColor == newColor) return;
    setState(() {
      _addNewLayer(newColor);
      _eraserOn = false;
    });
  }

  Future<void> _pickColor() async {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.lightBlue,
      Colors.blue,
      Colors.white,
      Colors.black,
    ];
    final pickedColor = await showDialog<Color>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('펜 색상'),
        content: SizedBox(
          width: 120,
          height: 100,
          child: Center(
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                for (final c in colors)
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx, c),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
        ],
      ),
    );

    if (pickedColor != null) {
      _applyPenColor(pickedColor);
    }
  }

  void _toggleEraser() {
    setState(() {
      _eraserOn = !_eraserOn;
    });
    _applyPenColor(_eraserOn ? _canvasBg : Colors.red);
  }

  _StrokeLayer? _findLayerById(int layerId) {
    try {
      return _layers.firstWhere((l) => l.id == layerId);
    } catch (_) {
      return null;
    }
  }

  void _onUndo() {
    if (_history.isEmpty) return;
    final last = _history.removeLast();
    final layer = _findLayerById(last.layerId);
    if (layer == null) return;

    layer.controller.undo();     // 해당 레이어의 마지막 스트로크 되돌리기
    _redoHistory.add(last);      // redo 스택에 푸시
    setState(() {});
  }

  void _onRedo() {
    if (_redoHistory.isEmpty) return;
    final last = _redoHistory.removeLast();
    final layer = _findLayerById(last.layerId);
    if (layer == null) return;

    layer.controller.redo();     // 해당 레이어의 마지막 취소 스트로크 다시 적용
    _history.add(last);          // undo 스택에 복귀
    setState(() {});
  }

  Future<void> _onSave() async {
    final rb = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (rb == null || _originalImageSize == Size.zero) return;

    // 모든 레이어에서 strokes 수집 + 각 스트로크에 해당 색상 맵핑
    final allStrokes = <List<List<double>>>[];
    final allStrokeColors = <img.Color>[];

    for (final layer in _layers) {
      final layerStrokes = collectStrokes(layer.controller);
      if (layerStrokes.isEmpty) continue;

      final c = layer.color;
      final cImg = img.ColorRgba8(c.red, c.green, c.blue, c.alpha);

      allStrokes.addAll(layerStrokes);
      allStrokeColors.addAll(List.generate(layerStrokes.length, (_) => cImg));
    }

    if (allStrokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ 낙서를 조금 더 해주세요')),
      );
      return;
    }

    final baseBytes = (await rootBundle.load(widget.imagePath)).buffer.asUint8List();
    final dir = await getApplicationDocumentsDirectory();

    // 폴백 색상(사용되지 않을 수 있지만 시그니처 호환용)
    final cur = _penColor;
    final penColorFallback = img.ColorRgba8(cur.red, cur.green, cur.blue, cur.alpha);

    final savedPath = await drawStrokesOnOriginalAndSave(
      baseImageBytes: baseBytes,
      strokes: allStrokes,
      boxSize: ui.Size(rb.size.width, rb.size.height),
      originalSize: ui.Size(_originalImageSize.width, _originalImageSize.height),
      penColor: penColorFallback,
      penStrokeWidth: _controller.penStrokeWidth,
      outputDirPath: dir.path,
      strokeColors: allStrokeColors,
    );

    for (final layer in _layers) {
      layer.controller.clear();
      layer.controller.dispose();
    }
    _layers.clear();
    _addNewLayer(Colors.red);

    widget.onSavedPath?.call(savedPath);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ 저장됨: $savedPath')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    for (final l in _layers) {
      l.controller.dispose();
    }
    _layers.clear();
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
          const SizedBox(height: 12),

          // Save button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.save, color: Colors.black),
                  label: const Text(
                    'Save',
                    style: TextStyle(fontSize: 15, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Image + multiple Signature layers
          AspectRatio(
            aspectRatio: aspectRatio,
            child: Stack(
              children: [
                // User image
                Positioned.fill(
                  child: Image.asset(
                    widget.imagePath,
                    key: _imageKey,
                    fit: BoxFit.contain,
                  ),
                ),
                // 모든 레이어 Signature (마지막 레이어만 입력 받음)
                for (int i = 0; i < _layers.length; i++)
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: i != _layers.length - 1,
                      child: Signature(
                        key: ValueKey('layer_$i${_layers[i].color}'),
                        controller: _layers[i].controller,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 5,
                  color: Colors.black26,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pen color picker
                IconButton(
                  tooltip: '펜 색상',
                  onPressed: _pickColor,
                  iconSize: 26,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.edit,
                    color: _eraserOn ? Colors.grey : _penColor,
                  ),
                ),
                const SizedBox(width: 8),

                // Eraser (배경색으로 그리기)
                IconButton(
                  tooltip: _eraserOn ? '지우개 끄기' : '지우개 켜기',
                  onPressed: _toggleEraser,
                  iconSize: 26,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.auto_fix_off,
                    color: _eraserOn ? Colors.black87 : Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),

                // Undo
                IconButton(
                  tooltip: '되돌리기',
                  onPressed: _onUndo,
                  iconSize: 26,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.undo),
                ),
                const SizedBox(width: 8),

                // Redo
                IconButton(
                  tooltip: '다시 실행',
                  onPressed: _onRedo,
                  iconSize: 26,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.redo),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
