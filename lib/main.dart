import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'diary_database.dart';

void main() {
  runApp(const MyApp());
  example();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Diary',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Diary Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _backupPath = '';
  String _txtPath = '';
  String _csvPath = '';

  Future<void> _backupDatabase() async {
    final path = await DiaryDatabase.instance.exportDatabase();
    setState(() {
      _backupPath = path;
    });
  }

  Future<void> _exportToTxt() async {
    final path = await DiaryDatabase.instance.exportToTxt();
    setState(() {
      _txtPath = path;
    });
  }

  Future<void> _exportToCsv() async {
    final path = await DiaryDatabase.instance.exportToCsv();
    setState(() {
      _csvPath = path;
    });
  }

  void _shareFile(String path) {
    Share.shareFiles([path], text: '共有するファイル: $path');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _backupDatabase,
              child: const Text('データベースをバックアップ'),
            ),
            if (_backupPath.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('バックアップファイルのパス:'),
              Text(_backupPath, textAlign: TextAlign.center),
              ElevatedButton(
                onPressed: () => _shareFile(_backupPath),
                child: const Text('バックアップファイルを共有'),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _exportToTxt,
              child: const Text('テキストファイルをエクスポート'),
            ),
            if (_txtPath.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('テキストファイルのパス:'),
              Text(_txtPath, textAlign: TextAlign.center),
              ElevatedButton(
                onPressed: () => _shareFile(_txtPath),
                child: const Text('テキストファイルを共有'),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _exportToCsv,
              child: const Text('CSVファイルをエクスポート'),
            ),
            if (_csvPath.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('CSVファイルのパス:'),
              Text(_csvPath, textAlign: TextAlign.center),
              ElevatedButton(
                onPressed: () => _shareFile(_csvPath),
                child: const Text('CSVファイルを共有'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

void example() async {
  await DiaryDatabase.instance.insertDiary('日記を書く', '今日はいい日だった');
  await DiaryDatabase.instance.insertDiary(
    '本を読む',
    'Flutterのチュートリアルを読んでいる',
  );

  final txtPath = await DiaryDatabase.instance.exportToTxt();
  print('テキストファイルを作成: $txtPath');

  final csvPath = await DiaryDatabase.instance.exportToCsv();
  print('CSVファイルを作成: $csvPath');

  final dbPath = await DiaryDatabase.instance.exportDatabase();
  print('データベースをバックアップ: $dbPath');
}
