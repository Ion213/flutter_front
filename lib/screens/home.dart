import 'package:flutter_app/screens/post_screen.dart';
import 'package:flutter_app/screens/profile.dart';
import 'package:flutter_app/services/user_service.dart';
import 'package:flutter/material.dart';

import 'login.dart';
import 'post_form.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JUHANBLOG'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Row(
                      children: [
                        Icon(
                          Icons.exit_to_app,
                          color: Colors.green,
                        ), // Add the icon here
                        SizedBox(width: 8),
                        Text('Logout'), // Title text
                      ],
                    ),
                    content: Text('Are you sure you want to logout?'),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ), // Add the icon for "No"
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.check_circle,
                          color: Colors.lightGreenAccent,
                        ), // Add the icon for "Yes"
                        onPressed: () {
                          logout().then((value) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => Login()),
                              (route) => false,
                            );
                          });
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: currentIndex == 0 ? PostScreen() : Profile(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PostForm(
                    title: 'Add new post',
                  )));
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.post_add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        notchMargin: 5,
        elevation: 10,
        clipBehavior: Clip.antiAlias,
        shape: CircularNotchedRectangle(),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.facebook), label: ''),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_box_sharp), label: '')
          ],
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.green,
          currentIndex: currentIndex,
          onTap: (val) {
            setState(() {
              currentIndex = val;
            });
          },
        ),
      ),
    );
  }
}
