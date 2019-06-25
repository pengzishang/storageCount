import 'package:equatable/equatable.dart';

class TotalData extends Equatable {
  DateTime timeId;
  DateTime updateTime;
  int totalCount;
  int damagedCount;
  int deliverCount;

  TotalData(
    int timeId,
    int updateTime,
    this.totalCount,
    this.damagedCount,
    this.deliverCount,
  ) : super([timeId, updateTime, totalCount, damagedCount, deliverCount]) {
    this.timeId = DateTime.fromMillisecondsSinceEpoch(timeId);
    this.updateTime = DateTime.fromMillisecondsSinceEpoch(updateTime);
  }
}

class EntryData extends Equatable {
  int entryId, numId;
  DateTime updateTime;
  DateTime createTime;
  bool isPacked, isDamaged, unknown;

  EntryData(this.entryId, this.numId, updateTime, createTime, isPacked,
      isDamaged, unknown)
      : super([
          entryId,
          updateTime,
          createTime,
          numId,
          isPacked,
          isDamaged,
          unknown
        ]) {
    this.updateTime = DateTime.fromMillisecondsSinceEpoch(updateTime);
    this.createTime = DateTime.fromMillisecondsSinceEpoch(createTime);
    this.isPacked = isPacked > 0;
    this.isDamaged = isDamaged > 0;
    this.unknown = unknown > 0;
  }
}
