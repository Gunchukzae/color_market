import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'doodle_page.dart';

class DoodleSaveInfo {
  final String mergedImagePath;
  DoodleSaveInfo({required this.mergedImagePath});
  Map<String, dynamic> toJson() => {'mergedImagePath': mergedImagePath};
  factory DoodleSaveInfo.fromJson(Map<String, dynamic> json) =>
      DoodleSaveInfo(mergedImagePath: json['mergedImagePath'] as String);
}

class DoodleControllerPage extends StatefulWidget {
  const DoodleControllerPage({super.key});

  @override
  State<DoodleControllerPage> createState() => _DoodleControllerPageState();
}

class _DoodleControllerPageState extends State<DoodleControllerPage> {
  final List<String> _imagePaths = const [
    'assets/images/apple.png',
    'assets/images/bread.png',
    'assets/images/egg.png',
  ];

  final Map<String, DoodleSaveInfo> _doodleInfos = {};

  @override
  void initState() {
    super.initState();
    _loadDoodles();
  }

  Future<void> _loadDoodles() async {
    // 매핑 JSON은 앱 문서폴더에 저장/로드
    final dir = await getApplicationDocumentsDirectory();
    for (final assetPath in _imagePaths) {
      final name = assetPath.split('/').last;                 // apple.png
      final jsonFile = File('${dir.path}/doodle_$name.json'); // …/doodle_apple.png.json

      if (await jsonFile.exists()) {
        final jsonMap = json.decode(await jsonFile.readAsString());
        final info = DoodleSaveInfo.fromJson(jsonMap);
        if (File(info.mergedImagePath).existsSync()) {
          _doodleInfos[assetPath] = info;
        }
      }
    }
    setState(() {});
  }

  Future<void> _handleSave(String assetPath, String savedAbsolutePath) async {
    // 1) 메모리 상태 갱신
    final info = DoodleSaveInfo(mergedImagePath: savedAbsolutePath);
    _doodleInfos[assetPath] = info;

    // 2) 매핑 JSON을 문서폴더에 저장
    final dir = await getApplicationDocumentsDirectory();
    final name = assetPath.split('/').last; // apple.png
    final jsonFile = File('${dir.path}/doodle_$name.json');
    await jsonFile.writeAsString(json.encode(info.toJson()));

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('낙서하기')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _imagePaths.length,
        itemBuilder: (context, index) {
          final assetPath = _imagePaths[index];
          final info = _doodleInfos[assetPath];

          // 존재 여부는 로딩 때 이미 걸렀다고 가정하고, 빌드에선 분기만
          final imageWidget = (info != null)
              ? Image.file(File(info.mergedImagePath), height: 400, fit: BoxFit.contain)
              : Image.asset(assetPath, height: 400, fit: BoxFit.contain);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DoodlePage(
                    imagePath: assetPath,
                    onSavedPath: (savedPath) async {
                      await _handleSave(assetPath, savedPath);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('✅ 저장 완료: $savedPath')),
                      );
                    },
                  ),
                ),
              );
            },
            child: imageWidget,
          );
        },
      ),
    );
  }
}
