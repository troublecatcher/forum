import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:store/const/AppColors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../forum_details_screen.dart';
import '../create_forum_screen.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List forums = [];
  List categories = [];
  var _firestoreInstance = FirebaseFirestore.instance;

  fetchCategories() async {
    QuerySnapshot qn = await _firestoreInstance.collection("categories").get();
    setState(() {
      for (int i = 0; i < qn.docs.length; i++) {
        categories.add({
          "name": qn.docs[i]["name"],
          "name0": qn.docs[i]["name0"],
          "icon": qn.docs[i]["icon"],
        });
      }
    });

    return qn.docs;
  }

  fetchIcon(String icon){
    Icon? ic;
    for (var element in categories) {
      if(element["name0"] == icon){
        ic = Icon(IconData(int.parse(element["icon"]), fontFamily: 'MaterialIcons'));
      }
    }
    return ic;
  }

  fetchForums() async {
    QuerySnapshot qn = await _firestoreInstance.collection("forums").get();
    setState(() {
      for (int i = 0; i < qn.docs.length; i++) {
        forums.add({
          "name": qn.docs[i]["name"],
          "desc": qn.docs[i]["desc"],
          "date": qn.docs[i]["date"],
          "cat": qn.docs[i]["cat"],
          "views": qn.docs[i]["views"],
          "author": qn.docs[i]["author"],
          "isclosed": qn.docs[i]["isclosed"],
          "responseCount": qn.docs[i]["responseCount"],
        });
      }
    });
    return qn.docs;
  }
  @override
  void initState() {
    fetchForums();
    fetchCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 15.h, top: 20.h,left: 20.w, right: 20.w),
            ),
            SizedBox(
              height: 10.h,
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: forums.length,
                  itemBuilder: (_, index) {
                    return GestureDetector(
                      onTap: ()=>{
                        Navigator.push(context, MaterialPageRoute(builder: (_)=>ForumDetails(forums[index])))
                      },
                      child: Card(
                        child: ListTile(
                          leading: fetchIcon(forums[index]["cat"].toString()),
                          title: Text(forums[index]["name"].toString(), style: TextStyle(color: Colors.black),),
                          subtitle: Text(forums[index]["desc"].toString(), style: TextStyle(color: Colors.black),),
                          trailing: TextButton.icon(onPressed: (){}, icon: Icon(Icons.message), label: Text(forums[index]['responseCount'].toString())),
                          )
                    ),
                    );
                  }),
            ),
          ],
        ),
      )),
    );
  }
}