class TotalData {
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
  ) {
    this.timeId = DateTime.fromMillisecondsSinceEpoch(timeId);
    this.updateTime = DateTime.fromMillisecondsSinceEpoch(updateTime);
  }
}

class EntryData {
  int entryId, numId;
  DateTime updateTime, createTime;
  bool isPacked, isDamaged, unknown;

  EntryData(this.entryId, this.numId, updateTimeStamp, createTimeStamp, isPacked,
      isDamaged, unknown) {
    this.updateTime = DateTime.fromMillisecondsSinceEpoch(updateTimeStamp);
    this.createTime = DateTime.fromMillisecondsSinceEpoch(createTimeStamp);
    this.isPacked = isPacked > 0;
    this.isDamaged = isDamaged > 0;
    this.unknown = unknown ?? 0 > 0;
  }
}
