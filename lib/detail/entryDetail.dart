//用一下listview自动生成
import 'package:flutter/material.dart';
import 'package:storage_count/db/totalData.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:storage_count/db/db.dart';

class ActionControl extends StatefulWidget {
  final EntryData initData;
  ActionControl(this.initData);

  @override
  _ActionControlState createState() => _ActionControlState();
}

class _ActionControlState extends State<ActionControl> {
  ActionControlModel _model = ActionControlModel();

  void initState() {
    super.initState();
    _model.entryData = widget.initData;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      child: ScopedModelDescendant(
        builder:
            (BuildContext context, Widget child, ActionControlModel model) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                "序号: " + widget.initData.numId.toString() + "的维护信息",
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                showDialog(
                        context: context,
                        builder: (BuildContext context) => InputDialog())
                    .then((onValue) {
                  model.insertActionData(
                      onValue[0], model.entryData.numId, model.entryData.numId);
                }).then((onValue) {
                  model.notifyListeners();
                });
              },
            ),
            body: ActionListView(),
          );
        },
      ),
      model: _model,
    );
  }
}

class InputDialog extends StatefulWidget {
  @override
  _InputDialogState createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  Function enabledFun() {
    if (content.length > 0) {
      return () {
        Navigator.pop(context, [content]);
      };
    } else {
      return null;
    }
  }

  String content = '';
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: <Widget>[
        SimpleDialogOption(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    content = value;
                  });
                },
              ),
              flex: 1,
            ),
            SizedBox(
              height: 10,
            ),
          ],
        )),
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

class ActionListView extends StatefulWidget {
  ActionListView({Key key}) : super(key: key);

  _ActionListViewState createState() => _ActionListViewState();
}

class _ActionListViewState extends State<ActionListView> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, ActionControlModel model) {
        model.getActionDataList();
        return ListView.separated(
          itemBuilder: (context, position) {
            Text(model.actionDatas[position].content);
          },
          separatorBuilder: (context, position) {
            return Container(
              height: 30,
              margin: EdgeInsets.all(30),
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(offset: Offset(2, 2), blurRadius: 1.0),
                  ]),
            );
          },
          itemCount: model.actionDatas.length,
        );
      },
    );
  }
}

class ActionControlModel extends Model {
  EntryData entryData;
  List<ActionData> _actionDatas = [];
  List<ActionData> get actionDatas {
    return _actionDatas;
  }

  Future getActionDataList() async {
    DBSharedInstance dbs = DBSharedInstance();
    actionDatas = await dbs.getActionData(entryData.numId);
  }

  Future<int> insertActionData(String content, int numId, int entryId) async {
    DBSharedInstance dbs = DBSharedInstance();
    return dbs.addActionData(content, numId, entryId);
  }

  set actionDatas(List<ActionData> list) {
    bool isEqual = true;
    if (_actionDatas.isNotEmpty) {
      _actionDatas.forEach((itemTotal) {
        int i = _actionDatas.indexOf(itemTotal);
        if (list[i] != itemTotal) {
          isEqual = false;
        }
      });
    } else if (_actionDatas.isEmpty && list.isEmpty) {
      isEqual = true;
    } else {
      isEqual = false;
    }
    if (isEqual == false) {
      _actionDatas = list;
      notifyListeners();
    }
  }
}
