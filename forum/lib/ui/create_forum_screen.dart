import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:store/ui/forum_details_screen.dart';

import 'bottom_nav_controller.dart';

class CreateForumScreen extends StatefulWidget {

  @override
  _CreateForumScreenState createState() => _CreateForumScreenState();
}

class _CreateForumScreenState extends State<CreateForumScreen> {
  String selectedOption = '';
  final nameController = TextEditingController();
  final descController = TextEditingController();
  var _firestoreInstance = FirebaseFirestore.instance;
  List categories = [];
  confirm(){
    if(nameController.text != '' && descController != '' && selectedOption != ''){
      String option = '';
      categories.forEach((element) {
        if(element['name'] == selectedOption){
          option = element['name0'];
        }
      });
      FirebaseFirestore.instance
          .collection("forums")
          .doc(nameController.text)
          .set({
        'author': FirebaseAuth.instance.currentUser!.email,
        'date': DateTime.now(),
        'cat': option,
        'desc': descController.text,
        'isclosed': false,
        'name': nameController.text,
        'responseCount': 0,
        'views': 0,
      });
      Fluttertoast.showToast(msg: 'Обсуждение успешно создано!');
      setState(() {
        Navigator.push(context, MaterialPageRoute(builder: (_)=>BottomNavController()));
      });
    }else Fluttertoast.showToast(msg: 'Введите все данные');
  }
  fetchCategories() async {
    QuerySnapshot qn = await _firestoreInstance.collection("categories").get();
    setState(() {
      for (int i = 0; i < qn.docs.length; i++) {
        categories.add({
          'name0': qn.docs[i]["name0"],
          'name': qn.docs[i]["name"],
        });
      }
    });

    return qn.docs;
  }
  var inputText = "";
  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    nameController.dispose();
    descController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    fetchCategories();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text("Категория", style: TextStyle(fontSize: 25),),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                children:
                categories
                    .map((e) => buildChip(e['name'], context))
                    .toList(),
              ),
              SizedBox(height: 20,),
              Text("Название", style: TextStyle(fontSize: 25),),
              TextFormField(
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white38,
                ),
                controller: nameController,
              ),
              SizedBox(height: 20,),
              Text("Вопрос", style: TextStyle(fontSize: 25),),
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white38,
                ),
                maxLines: 4,
                controller: descController,
              ),
              SizedBox(height: 20,),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    elevation: 10,
                  ),
                  onPressed: ()=>confirm(), child: Text("Создать", style: TextStyle(color: Colors.white),)),
            ],
          ),
        )
      ),
    );
  }
  Widget buildChip(String option, BuildContext context){
    final isSelected = selectedOption == option;
    final foregroundColor = isSelected? Colors.white : Colors.black;
    final backgroundColor = isSelected? Theme.of(context).primaryColor : Colors.white;
    return GestureDetector(
      onTap: () => setState(() {
        selectedOption = option;
      }),
      child: Chip(
        label: Text(
          option,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: foregroundColor,
          ),
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
