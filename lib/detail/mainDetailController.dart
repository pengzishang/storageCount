import 'package:flutter/material.dart';
import 'package:storage_count/db/db.dart';
import 'package:storage_count/db/totalData.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:storage_count/detail/entryDetail.dart';
import 'package:storage_count/main.dart' as Main;

class DetailHome extends StatefulWidget {
  final TotalData singleData;
  DetailHome(this.singleData);

  @override
  _DetailHomeState createState() => _DetailHomeState();
}

class _DetailHomeState extends State<DetailHome> {
  int tabberIndex = 0;
  String title = '总览';

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: MainDetailModel(),
      child: DefaultTabController(
        length: 2,
        child: ScopedModelDescendant<MainDetailModel>(
          rebuildOnChange: true,
          builder: (BuildContext context, Widget child, MainDetailModel model) {
            model.totalData = widget.singleData;
            model.getEntryDataList(model.orderBy, widget.singleData.timeId);
            return Scaffold(
              appBar: AppBar(
                title: Text(title),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return InputDialog();
                          });
                    },
                  )
                ],
              ),
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Main.InputDialog();
                      }).then((onValue) {
                    DBSharedInstance dbs = DBSharedInstance();
                    dbs.insertNewEntryDatas(int.tryParse(onValue[0]),
                        int.tryParse(onValue[1]), widget.singleData.timeId);
                    model.notifyListeners();
                  });
                },
              ),
              body: IndexedStack(
                index: tabberIndex,
                children: <Widget>[
                  BriefListView(),
                  Container(color: Colors.yellow),
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                // onTap: (int i) {
                //   setState(() {
                //     tabberIndex = i;
                //     title = ['总览', '表单信息'][i];
                //   });
                // },
                currentIndex: tabberIndex,
                type: BottomNavigationBarType.fixed,
                fixedColor: Colors.black,
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.ac_unit), title: Text('总览')),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.ac_unit), title: Text('表单信息')),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class InfoView extends StatelessWidget {
  const InfoView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[Container()],
    );
  }
}

class BriefListView extends StatefulWidget {
  @override
  _BriefListViewState createState() => _BriefListViewState();
}

class _BriefListViewState extends State<BriefListView> {
  int _sortColumnIndex = 0;
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainDetailModel>(
      rebuildOnChange: true,
      builder: (BuildContext context, Widget child, MainDetailModel model) {
        return ListView(
          padding: EdgeInsets.all(10),
          children: [
            DataTable(
              sortColumnIndex: _sortColumnIndex,
              sortAscending: true,
              columns: [
                DataColumn(
                    onSort: (index, ac) {
                      setState(() {
                        _sortColumnIndex = index;
                        model.orderBy = "numId";
                        model.entryList.sort((a, b) {
                          final c = a;
                          a = b;
                          b = c;
                          return a.numId.compareTo(b.numId);
                        });
                      });
                    },
                    label: SizedBox(
                      child: Text(
                        '序号',
                      ),
                    )),
                DataColumn(
                    onSort: (index, ac) {
                      setState(() {
                        _sortColumnIndex = index;
                        model.orderBy = "updateTimeStamp";
                        model.entryList.sort((a, b) {
                          final c = a;
                          a = b;
                          b = c;
                          return a.updateTime.millisecondsSinceEpoch
                              .compareTo(b.updateTime.millisecondsSinceEpoch);
                        });
                      });
                    },
                    label: Container(
                        padding: EdgeInsets.all(0),
                        child: Text(
                          '更新时间',
                          textAlign: TextAlign.center,
                        ))),
                DataColumn(
                  onSort: (index, ac) {
                    setState(() {
                      _sortColumnIndex = index;
                      model.orderBy = "isPacked";
                      model.getEntryDataList(
                          "isPacked", model.totalData.timeId);
                    });
                  },
                  label: Container(
                      child: Text(
                    '已出货',
                    textAlign: TextAlign.center,
                  )),
                ),
                DataColumn(
                  onSort: (index, ac) {
                    setState(() {
                      _sortColumnIndex = index;
                      model.orderBy = "isDamaged";
                      model.getEntryDataList(
                          "isDamaged", model.totalData.timeId);
                    });
                  },
                  label: Text(
                    '已损坏',
                  ),
                ),
                DataColumn(
                  onSort: (index, ac) {
                    setState(() {
                      _sortColumnIndex = index;
                      model.orderBy = "unknown";
                      model.getEntryDataList("unknown", model.totalData.timeId);
                    });
                  },
                  label: Text(
                    '未知',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              rows: model.entryList.map((EntryData entryValue) {
                return DataRow(
                  cells: [
                    DataCell(
                        Text(
                          entryValue.numId.toString(),
                          textAlign: TextAlign.center,
                        ), onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ActionControl(entryValue);
                      }));
                    }),
                    DataCell(
                      Text(
                        entryValue.updateTime.toString(),
                        textAlign: TextAlign.left,
                      ),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ActionControl(entryValue);
                        }));
                      },
                    ),
                    DataCell(Checkbox(
                      value: entryValue.isPacked,
                      onChanged: (value) {
                        setState(() {
                          entryValue.isPacked = !entryValue.isPacked;
                          DBSharedInstance dbs = DBSharedInstance();
                          dbs
                              .setEntryData(
                                  entryValue.numId,
                                  "isPacked",
                                  entryValue.isPacked,
                                  entryValue.createTime.millisecondsSinceEpoch)
                              .then((onValue) {
                            int i = 0;
                            model.entryList.forEach((item) {
                              if (item.isPacked) {
                                i++;
                              }
                            });
                            dbs.setTotalData(
                                model.totalData.timeId.millisecondsSinceEpoch,
                                "deliverCount",
                                i);
                          }).then((onValue) {
                            model.notifyListeners();
                          });
                        });
                      },
                    )),
                    DataCell(Checkbox(
                      value: entryValue.isDamaged,
                      onChanged: (value) {
                        setState(() {
                          entryValue.isDamaged = !entryValue.isDamaged;
                          DBSharedInstance dbs = DBSharedInstance();
                          dbs
                              .setEntryData(
                                  entryValue.numId,
                                  "isDamaged",
                                  entryValue.isDamaged,
                                  entryValue.createTime.millisecondsSinceEpoch)
                              .then((onValue) {
                            int i = 0;
                            model.entryList.forEach((item) {
                              if (item.isDamaged) {
                                i++;
                              }
                            });
                            dbs.setTotalData(
                                model.totalData.timeId.millisecondsSinceEpoch,
                                "damagedCount",
                                i);
                          }).then((onValue) {
                            model.notifyListeners();
                          });
                        });
                      },
                    )),
                    DataCell(Checkbox(
                      value: entryValue.unknown,
                      onChanged: (value) {
                        setState(() {
                          entryValue.unknown = !entryValue.unknown;
                          DBSharedInstance dbs = DBSharedInstance();
                          dbs
                              .setEntryData(
                                  entryValue.numId,
                                  "unknown",
                                  entryValue.unknown,
                                  entryValue.createTime.millisecondsSinceEpoch)
                              .then((onValue) {
                            dbs.setTotalData(
                                model.totalData.timeId.millisecondsSinceEpoch,
                                "",
                                0);
                          }).then((onValue) {
                            model.notifyListeners();
                          });
                        });
                      },
                    )),
                  ],
                );
              }).toList(),
            )
          ],
        );
      },
    );
  }
}

class MainDetailModel extends Model {
  String orderBy = "numId";
  TotalData totalData;
  List<EntryData> _entryList = [];
  List<EntryData> get entryList {
    return _entryList;
  }

  Future getEntryDataList(String orderBy, DateTime createTime) async {
    DBSharedInstance dbs = DBSharedInstance();
    entryList = await dbs.getEntryData(orderBy, createTime);
  }

  set entryList(List<EntryData> list) {
    bool isEqual = true;
    if (_entryList.length != list.length) {
      isEqual = false;
    } else {
      _entryList.forEach((itemTotal) {
        int i = _entryList.indexOf(itemTotal);
        if (list[i] != itemTotal) {
          isEqual = false;
        }
      });
    }

    if (isEqual == false) {
      _entryList = list;
      notifyListeners();
    }
  }
}
