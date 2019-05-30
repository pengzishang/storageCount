import 'package:flutter/material.dart';
import 'package:storage_count/db/totalData.dart';

class DetailHome extends StatefulWidget {
  final TotalData singleData;
  DetailHome(this.singleData);

  @override
  _DetailHomeState createState() => _DetailHomeState();
}

class _DetailHomeState extends State<DetailHome> {
  @override
  void initState() {
    super.initState();
    
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
            Container(
              color: Colors.red,
            ),
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
