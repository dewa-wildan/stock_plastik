import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'item.dart';
import '../Sqlite/dbhelper.dart';
import 'entryform.dart';
import '../menu.dart';

//pendukung program 
class Homeitem extends StatefulWidget {
  static const itemPage = '/home';

  static var homestock;
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Homeitem> {
  DbHelper dbHelper = DbHelper();
  int count = 0;
  List<Item> itemList;
  @override
  Widget build(BuildContext context) {
    if (itemList == null) {
      itemList = List<Item>();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('PLASTIK'),
        backgroundColor: Colors.grey[800],
      ),
      body: Column(children: [
        Expanded(
          child: createListView(),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: double.infinity,
            child: RaisedButton(
              child: Text("Tambah Plastik"),
              onPressed: () async {
                var item = await navigateToEntryForm(context, null);
                if (item != null) {
                  //TODO 2 memanggil Fungsi untuk Insert ke DB
                  int result = await dbHelper.insert(item);
                  if (result > 0) {
                    updateListView();
                  }
                }
              },
            ),
          ),
        ),
      ]),
    );
  }

  Future<Item> navigateToEntryForm(BuildContext context, Item item) async {
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return EntryForm(item);
    }));
    return result;
  }
  ListView createListView() {
    TextStyle textStyle = Theme.of(context).textTheme.headline5;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(Icons.grass),
            ),
            title: Text(
              this.itemList[index].nama,
              style: textStyle,
            ),
            subtitle: Text(this.itemList[index].harga.toString()),
            trailing: GestureDetector(
              child: Icon(Icons.delete),
              onTap: () async {

                //TODO 3 memanggil Fungsi untuk Delete dari DB berdasarkan Item
               dbHelper.delete(this.itemList[index].id);
                updateListView();
              },
            ),
            onTap: () async {
              var item =
                  await navigateToEntryForm(context, this.itemList[index]);
             
              //TODO 4 Untuk Memanggil Fungsi untuk Edit data
              if (item != null) {
                dbHelper.update(item);
                updateListView();
              }
            },
          ),
        );
      },
    );
  }

 //update untuk List item
  void updateListView() {
    final Future<Database> dbFuture = dbHelper.initDb();
    dbFuture.then((database) {

      //TODO 1 Select data dari DB
      Future<List<Item>> itemListFuture = dbHelper.getItemList();
      itemListFuture.then((itemList) {
        setState(() {
          this.itemList = itemList;
          this.count = itemList.length;
        });
      });
    });
  }
}


