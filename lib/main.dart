import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'detail/mainDetailController.dart';
import 'package:storage_count/db/db.dart';
import 'db/totalData.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new MainHome());
  }
}

class MainHome extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('所有项目'),
      ),
      key: _scaffoldKey,
      floatingActionButton: Builder(builder: (BuildContext context) {
        return FloatingActionButton(
          onPressed: () async {
            showDialog(
                    context: context,
                    builder: (BuildContext context) => InputDialog())
                .then((onValue) {
              if (onValue != null) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Adding'),
                  ),
                );

                DBSharedInstance dbs = DBSharedInstance();
                dbs
                    .createNewList(
                        int.tryParse(onValue.first), int.tryParse(onValue.last))
                    .then((onValue) {
                  Scaffold.of(context)
                      .hideCurrentSnackBar(reason: SnackBarClosedReason.hide);
                });
              }
            });
          },
          child: Icon(Icons.add),
        );
      }),
      body: TotalListView(),
    );
  }
}

class TotalListView extends StatefulWidget {
  @override
  _TotalListViewState createState() => _TotalListViewState();
}

class _TotalListViewState extends State<TotalListView> {
  List<TotalData> _totalDataList = [];
  int _sortColumnIndex = 0;

  @override
  initState() {
    super.initState();
    DBSharedInstance dbs = DBSharedInstance();

    dbs.getTotalDataList().then((onValue) {
      setState(() {
        _totalDataList = onValue;
      });
    });
  }

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
                  _totalDataList.sort((a, b) {
                    final c = a;
                    a = b;
                    b = c;
                    return a.timeId.millisecondsSinceEpoch
                        .compareTo(b.timeId.millisecondsSinceEpoch);
                  });
                });
              },
              label: Text(
                '更新时间',
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              onSort: (index, ac) {
                setState(() {
                  _sortColumnIndex = index;
                  _totalDataList.sort((a, b) {
                    final c = a;
                    a = b;
                    b = c;
                    return a.totalCount.compareTo(b.totalCount);
                  });
                });
              },
              label: Container(
                  child: Text(
                '总计',
                textAlign: TextAlign.center,
              )),
            ),
            DataColumn(
              onSort: (index, ac) {
                setState(() {
                  _sortColumnIndex = index;
                  _totalDataList.sort((a, b) {
                    final c = a;
                    a = b;
                    b = c;
                    return a.deliverCount.compareTo(b.deliverCount);
                  });
                });
              },
              label: Text(
                '已发货',
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              onSort: (index, ac) {
                setState(() {
                  _sortColumnIndex = index;
                  _totalDataList.sort((a, b) {
                    final c = a;
                    a = b;
                    b = c;
                    return a.damagedCount.compareTo(b.damagedCount);
                  });
                });
              },
              label: Text(
                '损坏数',
                textAlign: TextAlign.center,
              ),
            ),
          ],
          rows: _totalDataList.map((TotalData value) {
            return DataRow(
              cells: [
                DataCell(Text(
                  value.timeId.toString(),
                  textAlign: TextAlign.center,
                ),onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return DetailHome(value);
                  }));
                }),
                DataCell(Text(
                  value.totalCount.toString(),
                  textAlign: TextAlign.center,
                )),
                DataCell(Text(
                  value.deliverCount.toString(),
                  textAlign: TextAlign.center,
                )),
                DataCell(Text(
                  value.damagedCount.toString(),
                  textAlign: TextAlign.center,
                )),
              ],
              
            );
          }).toList(),
        )
      ],
    );
  }
}

class InputDialog extends StatefulWidget {
  @override
  _InputDialogState createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  Function enabledFun() {
    if (int.parse(firstString) < int.parse(lastString)) {
      return () {
        Navigator.pop(context, [firstString, lastString]);
      };
    } else {
      return null;
    }
  }

  String firstString = '0';
  String lastString = '0';

  @override
  void initState() {
    super.initState();
    firstString = '0';
    lastString = '0';
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: <Widget>[
        SimpleDialogOption(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flex(
                direction: Axis.horizontal,
                children: <Widget>[
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '从',
                      ),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      onChanged: (String str) {
                        setState(() {
                          firstString = str;
                        });
                      },
                    ),
                    flex: 3,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      '到',
                      textAlign: TextAlign.center,
                    ),
                    flex: 2,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '止',
                      ),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      onChanged: (String str) {
                        setState(() {
                          lastString = str;
                        });
                      },
                    ),
                    flex: 3,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              )
            ],
          ),
        ),
        SimpleDialogOption(
            child: RaisedButton(
          color: Colors.blue,
          onPressed: enabledFun(),
          elevation: 1.0,
          child: Text('确定'),
        )),
      ],
    );
  }
}
