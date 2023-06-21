import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:store/ui/bottom_nav_pages/home.dart';
import 'package:store/ui/bottom_nav_pages/profile.dart';
import 'package:store/ui/create_forum_screen.dart';

class BottomNavController extends StatefulWidget {
  @override
  _BottomNavControllerState createState() => _BottomNavControllerState();
}

class _BottomNavControllerState extends State<BottomNavController> {
  final List questions = <String>[
    'Выберите категорию',
    'Введите название',
    'Задайте вопрос',
  ];
  int question = -1;

  final _pages = [
    Home(),
    Profile(),
  ];
  var _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomSheet: question != -1 ? BottomSheetWidget(
      //   title: questions[question],
      //   options: categories,
      //   question: question,
      //   onClickedConfirm: () => setState(() {
      //     if(question >= questions.length - 1){
      //       question = -1;
      //     }else {
      //       question++;
      //     }
      //   }),
      //   onClickedClose: () => setState(() {
      //     question = -1;
      //   }),
      // ):null,

      appBar: AppBar(
        centerTitle: true,
        actions: <Widget>[
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (_)=>CreateForumScreen()));
          }, icon: Icon(
            Icons.add,
            color: Colors.white,
          ))
        ],
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Форум",
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 5,
        selectedItemColor: Colors.white,
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        selectedLabelStyle:
            TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Главная",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Профиль",
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: _pages[_currentIndex],
    );
  }
}
