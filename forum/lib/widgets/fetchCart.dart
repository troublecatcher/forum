import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget fetchCart (String collectionName){
  return StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection(collectionName)
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection("items")
        .snapshots(),
    builder:
        (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Text("Something is wrong"),
        );
      }

      return ListView.builder(
          itemCount: snapshot.data == null ? 0 : snapshot.data!.docs.length,
          itemBuilder: (_, index) {
            DocumentSnapshot _documentSnapshot = snapshot.data!.docs[index];
            return ListTile(
              title: Text(_documentSnapshot['name']),
              subtitle: Text(
                "${_documentSnapshot['price']} x ${_documentSnapshot['quantity']} = ${_documentSnapshot['price']*_documentSnapshot['quantity']} руб.",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    child: CircleAvatar(
                      child: Icon(Icons.remove),
                    ),
                    onTap: () {
                      FirebaseFirestore.instance
                          .collection(collectionName)
                          .doc(FirebaseAuth.instance.currentUser!.email)
                          .collection("items")
                          .doc(_documentSnapshot.id)
                          .update({
                        "quantity": _documentSnapshot['quantity'] - (_documentSnapshot['quantity'] == 1 ? 0:1),
                      });

                    },
                  ),
                  GestureDetector(
                    child: CircleAvatar(
                      child: Icon(Icons.delete),
                    ),
                    onTap: () {
                      FirebaseFirestore.instance
                          .collection(collectionName)
                          .doc(FirebaseAuth.instance.currentUser!.email)
                          .collection("items")
                          .doc(_documentSnapshot.id)
                          .delete();
                    },
                  )
                ],
              ),
            );
          });
    },
  );
}