import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';
import 'totalData.dart';

class DBSharedInstance {
  // 单例公开访问点
  factory DBSharedInstance() => _sharedInstance();

  // 静态私有成员，没有初始化
  static DBSharedInstance _instance;

  // 私有构造函数
  DBSharedInstance._() {
    // 具体初始化代码
  }

  // 静态、同步、私有访问点
  static DBSharedInstance _sharedInstance() {
    if (_instance == null) {
      _instance = DBSharedInstance._();
    }
    return _instance;
  }

  Future<String> get _dbPath async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    print(documentsDirectory.absolute);
    String path = Path.join(documentsDirectory.path, "db.db");
    return path;
  }

  Future<Database> get _dbFile async {
    final path = await _dbPath;
    if (File(path).existsSync()) {
      Database database = await openDatabase(path, version: 2);
      return database;
    } else {
      Database database = await openDatabase(path, version: 2,
          onCreate: (Database db, int version) async {
        await db.execute(
            "CREATE TABLE IF NOT EXISTS \"Total\" (\"timeStampId\" integer PRIMARY KEY NOT NULL,\"updateTime\" integer,\"totalCount\" integer NOT NULL DEFAULT(0),\"damagedCount\" integer NOT NULL DEFAULT(0),\"deliverCount\" integer NOT NULL DEFAULT(0));");
        await db.execute(
            "CREATE TABLE IF NOT EXISTS \"EntryDetail\" (\"entryId\" integer PRIMARY KEY AUTOINCREMENT NOT NULL,\"updateTimeStamp\" integer NOT NULL,\"createTimeStamp\" integer NOT NULL,\"numId\" integer NOT NULL,\"isPacked\" integer NOT NULL DEFAULT(0),\"isDamaged\" integer NOT NULL DEFAULT(0),\"unknown\" integer NOT NULL DEFAULT(0))");
        await db.execute(
            "CREATE TABLE IF NOT EXISTS \"ActionDetail\" (\"actionTimeId\" integer PRIMARY KEY NOT NULL,\"numId\" integer NOT NULL,\"content\" text,\"entryId\" integer NOT NULL);");
      });
      return database;
    }
  }

  Future<Database> createNewList(int from, int to) async {
    final db = await _dbFile;
    var time = DateTime.now().millisecondsSinceEpoch.toString();

    db.transaction((trx) {
      db.insert("Total", {
        "timeStampId": time,
        "updateTime": time,
        "totalCount": to - from + 1
      });
      List.generate(to - from + 1, (index) {
        return from + index;
      }).forEach((numId) {
        db.insert("EntryDetail",
            {"createTimeStamp": time, "updateTimeStamp": time, "numId": numId});
      });
    });

    return db;
  }

  Future closeDB() async {
    final db = await _dbFile;
    return db.close();
  }

  Future<List<TotalData>> getTotalDataList(String orderBy) async {
    final db = await _dbFile;
    List list = await db.query("Total", orderBy: orderBy);

    List<TotalData> totalLists = list
        .map((item) {
          return TotalData(item["timeStampId"], item["updateTime"],
              item["totalCount"], item["damagedCount"], item["deliverCount"]);
        })
        .toList()
        .reversed
        .toList();
    return totalLists;
  }

  void insertNewEntryDatas(int from, int to, DateTime createTime) async {
    final db = await _dbFile;
    var time = DateTime.now().millisecondsSinceEpoch;

    Set newAddSet = Set.from(List.generate(to - from + 1, (index) {
      return from + index;
    }));
    getEntryData("numId", createTime).then((onValue) {
      Set numIds = onValue.map((item) {
        return item.numId;
      }).toSet();
      List difference = newAddSet.difference(numIds).toList();
      difference.forEach((item) {
        db.insert("EntryDetail", {
          "createTimeStamp": createTime.millisecondsSinceEpoch,
          "updateTimeStamp": time,
          "numId": item
        });
      });
      db.update("Total", {"updateTime":time,"totalCount":newAddSet.union(numIds).length});
    });
  }

  Future<List<EntryData>> getEntryData(
      String orderBy, DateTime createTime) async {
    final db = await _dbFile;
    List list = await db.query("EntryDetail",
        columns: [
          "entryId",
          "updateTimeStamp",
          "createTimeStamp",
          "numId",
          "isPacked",
          "isDamaged",
          "unknown"
        ],
        where: "createTimeStamp = ?",
        whereArgs: [createTime.millisecondsSinceEpoch],
        orderBy: orderBy);
    return list
        .map((value) {
          return EntryData(
              value["entryId"],
              value["numId"],
              value["updateTimeStamp"],
              value["createTimeStamp"],
              value["isPacked"],
              value["isDamaged"],
              value["unknown"]);
        })
        .toList()
        .reversed
        .toList();
  }

  Future<int> setEntryData(int numId, String targetParm, bool targetValue,
      int createTimeStamp) async {
    final db = await _dbFile;
    return db.transaction((action) {
      action.update(
          "EntryDetail",
          {
            targetParm: targetValue ? 1 : 0,
            "updateTimeStamp": DateTime.now().millisecondsSinceEpoch
          },
          where: "numId =? AND createTimeStamp =?",
          whereArgs: [numId, createTimeStamp]);
    });
  }

  Future<int> setTotalData(
      int timeId, String targetParm, int targetValue) async {
    final db = await _dbFile;
    return db.transaction((action) {
      if (targetParm.length != 0) {
        action.update("Total", {targetParm: targetValue},
            where: "timeStampId =?", whereArgs: [timeId]);
      }

      action.update(
          "Total", {"updateTime": DateTime.now().millisecondsSinceEpoch},
          where: "timeStampId =?", whereArgs: [timeId]);
    });
  }

  Future<List<ActionData>> getActionData(int numId, int entryId) async {
    final db = await _dbFile;
    List list = await db.query("ActionDetail",
        columns: ["actionTimeId", "numId", "content", "entryId"],
        where: "numId = ? AND entryId = ?",
        whereArgs: [numId, entryId],
        orderBy: "actionTimeId");

    return list
        .map((item) {
          return ActionData(item["actionTimeId"], item["numId"],
              item["content"], item["entryId"]);
        })
        .toList()
        .reversed
        .toList();
  }

  Future<int> addActionData(String content, int numId, int entryId) async {
    final db = await _dbFile;
    return db.transaction((action) {
      db.insert("ActionDetail", {
        "actionTimeId": DateTime.now().millisecondsSinceEpoch,
        "content": content,
        "numId": numId,
        "entryId": entryId
      });
      db.update("EntryDetail",
          {"updateTimeStamp": DateTime.now().millisecondsSinceEpoch},
          where: "entryId = ?", whereArgs: [entryId]);

      db.query("EntryDetail", where: "entryId = ?", whereArgs: [
        entryId
      ], columns: [
        "entryId",
        "updateTimeStamp",
        "createTimeStamp",
        "numId",
        "isPacked",
        "isDamaged",
        "unknown"
      ]).then((value) {
        int createTimeStamp = value[0]["createTimeStamp"];
        db.update(
            "Total", {"updateTime": DateTime.now().millisecondsSinceEpoch},
            where: "timeStampId = ?", whereArgs: [createTimeStamp]);
      });
    });
  }
}
