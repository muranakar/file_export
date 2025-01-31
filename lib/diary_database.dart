import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class DiaryDatabase {
  static final DiaryDatabase instance = DiaryDatabase._init();
  static Database? _database;

  DiaryDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('diary.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE diaries (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      content TEXT,
      created_at TEXT
    )
    ''');
  }

  String _formattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd-HH:mm');
    return formatter.format(now);
  }

  Future<String> exportToTxt() async {
    final db = await database;
    final diaries = await db.query('diaries');

    final docDir = await getApplicationDocumentsDirectory();
    final txtFile = File(join(docDir.path, 'diaries_${_formattedDate()}.txt'));

    final buffer = StringBuffer();
    buffer.writeln('===== 日記リスト =====');

    for (var diary in diaries) {
      buffer.writeln('ID: ${diary['id']}');
      buffer.writeln('タイトル: ${diary['title']}');
      buffer.writeln('内容: ${diary['content']}');
      buffer.writeln('作成日時: ${diary['created_at']}');
      buffer.writeln('-------------------');
    }

    await txtFile.writeAsString(buffer.toString());
    return txtFile.path;
  }

  Future<String> exportToCsv() async {
    final db = await database;
    final diaries = await db.query('diaries');

    final docDir = await getApplicationDocumentsDirectory();
    final csvFile = File(join(docDir.path, 'diaries_${_formattedDate()}.csv'));

    final buffer = StringBuffer();
    buffer.writeln('id,title,content,created_at');

    for (var diary in diaries) {
      final values = [
        diary['id'],
        '"${diary['title']}"',
        '"${diary['content']}"',
        diary['created_at']
      ];
      buffer.writeln(values.join(','));
    }

    await csvFile.writeAsString(buffer.toString());
    return csvFile.path;
  }

  Future<String> exportDatabase() async {
    final db = await database;

    try {
      if (_database != null && _database!.isOpen) {
        await _database!.close();
        _database = null;
      }

      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, 'diary.db'));

      final docDir = await getApplicationDocumentsDirectory();
      final backupPath =
          join(docDir.path, 'diary_backup_${_formattedDate()}.db');

      await dbFile.copy(backupPath);
      return backupPath;
    } catch (e) {
      print('バックアップエラー: $e');
      rethrow;
    }
  }

  Future<void> insertDiary(String title, String content) async {
    final db = await database;
    await db.insert('diaries', {
      'title': title,
      'content': content,
      'created_at': DateTime.now().toIso8601String()
    });
  }
}
