import 'package:flutter/material.dart';
import 'package:storage_count/db/db.dart';
import 'package:storage_count/db/totalData.dart';

class DetailHome extends StatefulWidget {
  final TotalData singleData;
  List<EntryData> entryList = [];
  EntryData _currentData;
  DetailHome(this.singleData);

  @override
  _DetailHomeState createState() => _DetailHomeState();
}

class _DetailHomeState extends State<DetailHome> {
  @override
  void initState() {
    super.initState();
    DBSharedInstance().getEntryData(widget.singleData.timeId).then((value) {
      setState(() {
        widget.entryList = value;
      });
    });
  }

  int c_index = 0;
  String c_title = '总览';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(c_title),
        ),
        body: IndexedStack(
          index: c_index,
          children: <Widget>[
            BriefListView(widget.entryList),
            Container(
              color: Colors.green,
            ),
            Container(color: Colors.yellow),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (int i) {
            setState(() {
              c_index = i;
              c_title = ['总览', '异常', '表单信息'][i];
            });
          },
          currentIndex: c_index,
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
      ),
    );
  }
}

class BriefListView extends StatefulWidget {
  List<EntryData> entryList = [];
  BriefListView(this.entryList);

  @override
  _BriefListViewState createState() => _BriefListViewState();
}

class _BriefListViewState extends State<BriefListView> {
  int _sortColumnIndex = 0;
  @override
  Widget build(BuildContext context) {
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
                    widget.entryList.sort((a, b) {
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
                    widget.entryList.sort((a, b) {
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
                  widget.entryList.sort((a, b) {
                    final c = a;
                    a = b;
                    b = c;
                    return int.parse(a.isPacked.toString())
                        .compareTo(int.parse(b.isPacked.toString()));
                  });
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
                  widget.entryList.sort((a, b) {
                    final c = a;
                    a = b;
                    b = c;
                    return int.parse(a.isDamaged.toString())
                        .compareTo(int.parse(b.isDamaged.toString()));
                  });
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
                  widget.entryList.sort((a, b) {
                    final c = a;
                    a = b;
                    b = c;
                    return int.parse(a.unknown.toString())
                        .compareTo(int.parse(b.unknown.toString()));
                  });
                });
              },
              label: Text(
                '未知',
                textAlign: TextAlign.center,
              ),
            ),
          ],
          rows: widget.entryList.map((EntryData value) {
            return DataRow(
              cells: [
                DataCell(
                    Text(
                      value.numId.toString(),
                      textAlign: TextAlign.center,
                    ), onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
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
  }
}
