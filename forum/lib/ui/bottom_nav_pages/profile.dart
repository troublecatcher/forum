import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:store/ui/login_screen.dart';
import 'package:store/widgets/fetchProducts.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../widgets/fetchOrders.dart';

class Profile extends StatefulWidget {

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var name = TextEditingController();
  var phone = TextEditingController();
  var oldPwd = TextEditingController();
  var newPwd = TextEditingController();
  var newPwdAgain = TextEditingController();

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }
  confirmChange({email, oldpwd, newpwd})async{
    final user = FirebaseAuth.instance.currentUser!;
// you should check here that email is not empty
    final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPwd.text);
    try {
      await user.reauthenticateWithCredential(credential);
      try {
        await user.updatePassword(newPwd.text);
        _signOut();
        Fluttertoast.showToast(msg: 'Вы сменили пароль, войдите заново');
      } catch (e) {
        rethrow;
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: 'Старый пароль неверный');
    }

  }
  changePwd() => showDialog(
      context: context,
      builder: (context)=> AlertDialog(
        title: Text('Меняем пароль', style: TextStyle(color: Colors.black),),
        content: Wrap(
          children: [
            TextField(
              obscureText: true,
              style: TextStyle(color: Colors.black),
              controller: oldPwd,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white38,
                labelText: 'Старый пароль',
                labelStyle: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ),
            TextField(
              obscureText: true,
              style: TextStyle(color: Colors.black),
              controller: newPwd,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white38,
                labelText: 'Новый пароль',
                labelStyle: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ),
            TextField(
              obscureText: true,
              style: TextStyle(color: Colors.black),
              controller: newPwdAgain,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white38,
                labelText: 'Еще раз',
                labelStyle: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
        actions: [
          TextButton(
              onPressed: (){
                // FirebaseFirestore.instance
                //     .collection('forums')
                //     .doc(widget.forum['name'])
                //     .collection('responses')
                //     .doc(id).set({
                //   'isbest': true,
                // },SetOptions(merge: true));
                // FirebaseFirestore.instance
                //     .collection('forums')
                //     .doc(widget.forum['name']).set({
                //   'isclosed': true,
                // },SetOptions(merge: true));
                // setState(() {
                //   Navigator.push(context, MaterialPageRoute(builder: (_)=>BottomNavController()));
                // });
                if(newPwdAgain.text != newPwd.text){
                  Fluttertoast.showToast(msg: 'Пароли не совпадают');
                }else{
                  confirmChange();
                  Navigator.of(context).pop();
                }
              },
              child: Text("Подтвердить")),
          TextButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Text("Отмена")),
        ],
      ));
  setDataToTextField(data){
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text("Имя"),
          TextFormField(
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white38,
            ),
            controller: name = TextEditingController(text: data['name']),
          ),
          SizedBox(
            height: 15,
          ),
          Text("Телефон"),
          TextFormField(
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white38,
            ),
            controller: phone = TextEditingController(text: data['phone']),
          ),
          SizedBox(
            height: 15,
          ),
          SizedBox(
            height: 15,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 10,
              ),
              onPressed: ()=>updateData(), child: Text("Обновить", style: TextStyle(color: Colors.black),)),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                elevation: 10,
              ),
              onPressed: ()=>changePwd(), child: Text("Сменить пароль", style: TextStyle(color: Colors.white),)),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                elevation: 10,
              ),
              onPressed: ()=>_signOut(), child: Text("Выйти", style: TextStyle(color: Colors.white),)),
          SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  updateData(){
    CollectionReference _collectionRef = FirebaseFirestore.instance.collection("users-form-data");
    return _collectionRef.doc(FirebaseAuth.instance.currentUser!.email).update(
        {
          "name":name!.text,
          "phone":phone!.text,
        }
    ).then((value) => Fluttertoast.showToast(msg: "Успешно обновлено!"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget> [
                SizedBox(
                  height: 15,
                ),
                Center(
                    child: Text('Личный кабинет', style: TextStyle(fontSize: 18),)
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("users-form-data").doc(FirebaseAuth.instance.currentUser!.email).snapshots(),
                  builder: (BuildContext context, AsyncSnapshot snapshot){
                    var data = snapshot.data;
                    if(data==null){
                      return Center(child: CircularProgressIndicator(),);
                    }
                    return setDataToTextField(data);
                  },

                ),
              ],
            ),
          )
      ),
    );
  }
}