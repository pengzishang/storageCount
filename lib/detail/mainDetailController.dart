import 'package:flutter/material.dart';
import 'package:storage_count/db/db.dart';
import 'package:storage_count/db/totalData.dart';
import 'package:scoped_model/scoped_model.dart';

class DetailHome extends StatefulWidget {
  final TotalData singleData;
  // List<EntryData> entryList = [];
  // EntryData _currentData;
  DetailHome(this.singleData);

  @override
  _DetailHomeState createState() => _DetailHomeState();
}

class _DetailHomeState extends State<DetailHome> {
  int tabberIndex = 0;
  String title = '总览';

  String orderBy = "numId";

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: ScopedModelDescendant<MainDetailModel>(
        rebuildOnChange: true,
        builder: (BuildContext context, Widget child, MainDetailModel model) {
          model.getEntryDataList(orderBy, widget.singleData.timeId);
          return Scaffold(
            appBar: AppBar(
              title: Text(title),
            ),
            body: IndexedStack(
              index: tabberIndex,
              children: <Widget>[
                BriefListView(),
                Container(
                  color: Colors.green,
                ),
                Container(color: Colors.yellow),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              onTap: (int i) {
                setState(() {
                  tabberIndex = i;
                  title = ['总览', '异常', '表单信息'][i];
                });
              },
              currentIndex: tabberIndex,
              type: BottomNavigationBarType.fixed,
              fixedColor: Colors.black,
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.ac_unit), title: Text('总览')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.ac_unit), title: Text('异常')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.ac_unit), title: Text('表单信息')),
              ],
            ),
          );
        },
      ),
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
                    // setState(() {
                    //   _sortColumnIndex = index;
                    //   widget.entryList.sort((a, b) {
                    //     final c = a;
                    //     a = b;
                    //     b = c;
                    //     return int.parse(a.isPacked.toString())
                    //         .compareTo(int.parse(b.isPacked.toString()));
                    //   });
                    // });
                  },
                  label: Container(
                      child: Text(
                    '已出货',
                    textAlign: TextAlign.center,
                  )),
                ),
                DataColumn(
                  onSort: (index, ac) {
                    // setState(() {
                    //   _sortColumnIndex = index;
                    //   widget.entryList.sort((a, b) {
                    //     final c = a;
                    //     a = b;
                    //     b = c;
                    //     return int.parse(a.isDamaged.toString())
                    //         .compareTo(int.parse(b.isDamaged.toString()));
                    //   });
                    // });
                  },
                  label: Text(
                    '已损坏',
                  ),
                ),
                DataColumn(
                  onSort: (index, ac) {
                    // setState(() {
                    //   _sortColumnIndex = index;
                    //   widget.entryList.sort((a, b) {
                    //     final c = a;
                    //     a = b;
                    //     b = c;
                    //     return int.parse(a.unknown.toString())
                    //         .compareTo(int.parse(b.unknown.toString()));
                    //   });
                    // });
                  },
                  label: Text(
                    '未知',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              rows: model.entryList.map((EntryData value) {
                return DataRow(
                  cells: [
                    DataCell(
                        Text(
                          value.numId.toString(),
                          textAlign: TextAlign.center,
                        ), onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        //todo
                        // return DetailHome(value);
                      }));
                    }),
                    DataCell(Text(
                      value.updateTime.toString(),
                      textAlign: TextAlign.left,
                    )),
                    DataCell(Checkbox(
                      value: value.isPacked,
                      onChanged: (value) {},
                    )),
                    DataCell(Checkbox(
                      value: value.isPacked,
                      onChanged: (value) {},
                    )),
                    DataCell(Checkbox(
                      value: value.unknown,
                      onChanged: (value) {},
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
  List<EntryData> _entryList = [];
  List<EntryData> get entryList {
    return _entryList;
  }

  Future getEntryDataList(String orderBy, DateTime createTime) async {
    DBSharedInstance dbs = DBSharedInstance();
    entryList = await dbs.getEntryData(orderBy, createTime);
  }

  set entryList(List<EntryData> list) {

    
    _entryList = list;
    notifyListeners();
  }
}
