import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/intl.dart';
import 'package:store/const/AppColors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:store/ui/bottom_nav_controller.dart';
import 'package:store/ui/bottom_nav_pages/home.dart';

class ForumDetails extends StatefulWidget {
  var forum;
  ForumDetails(this.forum);
  @override
  _ForumDetailsState createState() => _ForumDetailsState();
}
final FirebaseAuth _auth = FirebaseAuth.instance;
var currentUser = _auth.currentUser;
var _firestoreInstance = FirebaseFirestore.instance;
class _ForumDetailsState extends State<ForumDetails> {

  int length = 0;
  late TextEditingController controller;
  List categories = [];
  List users = [];
  int views = 0;
  fetchCategories() async {
    QuerySnapshot qn = await _firestoreInstance.collection("categories").get();
    setState(() {
      for (int i = 0; i < qn.docs.length; i++) {
        categories.add({
          "name": qn.docs[i]["name"],
          "name0": qn.docs[i]["name0"],
          "icon": qn.docs[i]["icon"]
        });
      }
    });

    return qn.docs;
  }
  fetchUsers() async {
    QuerySnapshot qn = await _firestoreInstance.collection("users-form-data").get();
    setState(() {
      for (int i = 0; i < qn.docs.length; i++) {
        users.add({
          "email": qn.docs[i].id,
          "name": qn.docs[i]["name"],
        });
      }
    });

    return qn.docs;
  }
  fetchIcon(String icon){
    Icon? ic;
    for (var element in categories) {
      if(element["name0"] == icon){
        ic = Icon(IconData(int.parse(element["icon"]), fontFamily: 'MaterialIcons'),color: Colors.orange,);
      }
    }
    return ic;
  }
  submit(){
    FirebaseFirestore.instance
        .collection('forums')
        .doc(widget.forum['name'])
        .collection('responses')
        .doc()
        .set({
      'author': FirebaseAuth.instance.currentUser!.email,
      'comment': controller.text,
      'date': DateTime.now(),
      'isbest': false,
    });
    FirebaseFirestore.instance
        .collection('forums')
        .doc(widget.forum['name'])
        .set({
      'responseCount': widget.forum['responseCount'] + 1,
    }, SetOptions(merge: true));
    setState(() {
      Navigator.of(context).pop(controller.text);
    });
  }
  fetchCat(String name){
    String? n;
    for (var element in categories) {
      if(element["name0"] == name){
        n = element['name'];
      }
    }
    return n;
  }
  Future<String?> commentDialog() => showDialog<String>(
      context: context,
      builder: (context)=> AlertDialog(
        title: Text('Ваш комментарий', style: TextStyle(color: Colors.black),),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(hintText: "Введите здесь свой комментарий..."),
        ),
        actions: [
          TextButton(
              onPressed: (){
                submit();
              },
                child: Text("ОПУБЛИКОВАТЬ")),
        ],
      ));
  Future<String?> closeDialog(String id) => showDialog<String>(
      context: context,
      builder: (context)=> AlertDialog(
        title: Text('Уверены, что этот ответ – лучший?', style: TextStyle(color: Colors.black),),
        actions: [
          TextButton(
              onPressed: (){
                FirebaseFirestore.instance
                    .collection('forums')
                    .doc(widget.forum['name'])
                    .collection('responses')
                    .doc(id).set({
                  'isbest': true,
                },SetOptions(merge: true));
                FirebaseFirestore.instance
                    .collection('forums')
                    .doc(widget.forum['name']).set({
                  'isclosed': true,
                },SetOptions(merge: true));
                setState(() {
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>BottomNavController()));
                });
              },
              child: Text("Да, закрыть обсуждение")),
          TextButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Text("Нет")),
        ],
      ));

  fetchDate(Timestamp ts){
    var date = DateTime.fromMillisecondsSinceEpoch(ts.millisecondsSinceEpoch);
    var d = '${date.day}.${date.month}.${date.year}, ${date.hour}:${date.minute}:${date.second}';
    return Text(d, style: TextStyle(color: Colors.black),);
  }
  makeBest(String id)async{
    final comment = await closeDialog(id);
  }
  checkAuthority(String id){
    if(!widget.forum['isclosed']){
      if(FirebaseAuth.instance.currentUser!.email == widget.forum['author']){
        return GestureDetector(
          onTap: ()=>makeBest(id),
          child: Icon(Icons.check),
        );
      }
    }
    return Text('');
  }

  getLikes(String id)async{
    QuerySnapshot qn = await FirebaseFirestore.instance
        .collection('forums')
        .doc(widget.forum['name'])
        .collection('responses')
        .doc(id)
        .collection('likes').get();
    return Text(qn.docs.length.toString());
  }
  getDislikes(String id)async{
    QuerySnapshot qn = await FirebaseFirestore.instance
        .collection('forums')
        .doc(widget.forum['name'])
        .collection('responses')
        .doc(id)
        .collection('dislikes').get();
    return Text(qn.docs.length.toString());
  }
  getUser(String email){
    var n = '';
    for (var element in users) {
      if(element['email'] == email)
        n =  element['name'];
    }
    return n;
  }
  @override
  void initState() {
    controller = TextEditingController();
    fetchCategories();
    fetchUsers();
    FirebaseFirestore.instance
        .collection("forums")
        .doc(widget.forum['name'])
        .set({
      'views': widget.forum['views'] + 1,
    },SetOptions(merge: true));
    super.initState();
  }
  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if(categories.isEmpty) return CircularProgressIndicator(
      color: Colors.white,
    );
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.forum['isclosed']? null:()=>commentDialog(),
        backgroundColor: widget.forum['isclosed']? Colors.grey:Colors.deepOrange,
          icon: const Icon(Icons.message), label: Text('ОТВЕТИТЬ'),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                )),
          ),
        ),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.forum['name'],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    fetchIcon(widget.forum['cat'].toString()),
                    SizedBox(width: 10),
                    Text(
                      fetchCat(widget.forum['cat']),
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(widget.forum['isclosed']==false?Icons.check_box_outline_blank:Icons.check_box,color:Colors.orange),
                    SizedBox(width: 10),
                    Text(
                      widget.forum['isclosed']==false?"Не отвечено":"Отвечено",
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.remove_red_eye,color:Colors.orange),
                    SizedBox(width: 10),
                    Text(
                      widget.forum['views'].toString(),
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                )
              ],
            ),
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                   ListTile(
                    leading: Icon(Icons.person),
                    minVerticalPadding: 10,
                    title: Text(getUser(widget.forum['author']), style: TextStyle(color: Colors.orange),),
                    subtitle: Text(widget.forum['desc'],style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      fetchDate(widget.forum['date']),
                      const SizedBox(width: 8),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(child:
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('forums')
                  .doc(widget.forum['name'])
                  .collection('responses')
                  .snapshots(),
              builder:
                  (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Something is wrong"),
                  );
                }
                return Padding(
                  padding: EdgeInsets.only(left: 20),
                  child:
                  ListView.builder(
                      itemCount: snapshot.data == null ? 0 : snapshot.data!.docs.length,
                      itemBuilder: (_, index) {
                        length = snapshot.data!.docs.length;
                        DocumentSnapshot _documentSnapshot = snapshot.data!.docs[index];
                        return Card(
                          color: snapshot.data!.docs[index]['isbest']?Colors.orange:Colors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: Column(
                                  children: [
                                    Icon(Icons.person),
                                    checkAuthority(_documentSnapshot.id),
                                  ],
                                ),
                                title: Text(getUser(snapshot.data!.docs[index]['author']), style: TextStyle(color: snapshot.data!.docs[index]['isbest']?Colors.white:Colors.orange),),
                                subtitle: Text(_documentSnapshot['comment'],style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  fetchDate(_documentSnapshot['date']),
                                  IconButton(
                                    icon: const Icon(Icons.thumb_up),
                                    onPressed: () {
                                      setState(() {
                                        FirebaseFirestore.instance
                                            .collection('forums')
                                            .doc(widget.forum['name'])
                                            .collection('responses')
                                            .doc(_documentSnapshot.id)
                                            .collection('likes')
                                            .doc(FirebaseAuth.instance.currentUser!.email).set({});
                                        FirebaseFirestore.instance
                                            .collection('forums')
                                            .doc(widget.forum['name'])
                                            .collection('responses')
                                            .doc(_documentSnapshot.id)
                                            .collection('dislikes')
                                            .doc(FirebaseAuth.instance.currentUser!.email).delete();
                                      });
                                    },
                                  ),
                                  StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('forums')
                                          .doc(widget.forum['name'])
                                          .collection('responses')
                                          .doc(_documentSnapshot.id)
                                          .collection('likes').snapshots(),
                                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                                        switch(snapshot.connectionState){
                                          case ConnectionState.none:
                                          case ConnectionState.waiting:
                                            return CircularProgressIndicator();
                                          case ConnectionState.active:
                                            return Text(snapshot.data!.docs.length.toString(), style: TextStyle(color: Colors.black),);

                                          case ConnectionState.done:
                                            return Text(snapshot.data!.docs.length.toString(), style: TextStyle(color: Colors.black),);
                                        }
                                      }),
                                  IconButton(
                                    icon: const Icon(Icons.thumb_down),
                                    onPressed: () {
                                      setState(() {
                                        setState(() {
                                          FirebaseFirestore.instance
                                              .collection('forums')
                                              .doc(widget.forum['name'])
                                              .collection('responses')
                                              .doc(_documentSnapshot.id)
                                              .collection('dislikes')
                                              .doc(FirebaseAuth.instance.currentUser!.email).set({});
                                          FirebaseFirestore.instance
                                              .collection('forums')
                                              .doc(widget.forum['name'])
                                              .collection('responses')
                                              .doc(_documentSnapshot.id)
                                              .collection('likes')
                                              .doc(FirebaseAuth.instance.currentUser!.email).delete();
                                        });
                                      });
                                    },
                                  ),
                                  StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('forums')
                                          .doc(widget.forum['name'])
                                          .collection('responses')
                                          .doc(_documentSnapshot.id)
                                          .collection('dislikes').snapshots(),
                                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                                        switch(snapshot.connectionState){
                                          case ConnectionState.none:
                                          case ConnectionState.waiting:
                                            return CircularProgressIndicator();
                                          case ConnectionState.active:
                                            return Text(snapshot.data!.docs.length.toString(), style: TextStyle(color: Colors.black),);
                                          case ConnectionState.done:
                                            return Text(snapshot.data!.docs.length.toString(), style: TextStyle(color: Colors.black),);
                                        }
                                      }),
                                ],
                              ),
                            ],
                          ),
                        );
                      }));
              },
            )
            )
          ],
        ),
      )),
    );
  }
}
