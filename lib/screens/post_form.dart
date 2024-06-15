import 'package:flutter_app/constant.dart';
import 'package:flutter_app/models/api_response.dart';
import 'package:flutter_app/models/post.dart';
import 'package:flutter_app/services/post_service.dart';
import 'package:flutter_app/services/user_service.dart';
import 'package:flutter/material.dart';

import 'login.dart';

class PostForm extends StatefulWidget {
  final Post? post;
  final String? title;

  PostForm({this.post, this.title});

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _txtControllerBody = TextEditingController();
  bool _loading = false;

  void _createPost() async {
    ApiResponse response = await createPost(_txtControllerBody.text);

    if (response.error == null) {
      Navigator.of(context).pop();
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
      setState(() {
        _loading = !_loading;
      });
    }
  }

  // edit post
  void _editPost(int postId) async {
    ApiResponse response = await editPost(postId, _txtControllerBody.text);
    if (response.error == null) {
      Navigator.of(context).pop();
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
      setState(() {
        _loading = !_loading;
      });
    }
  }

  Widget kTextButton(String text, Function onPressed,
      {IconData? icon, Color? color}) {
    return TextButton(
      onPressed: onPressed as void Function()?,
      style: TextButton.styleFrom(
        primary: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, color: color),
          SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  @override
  void initState() {
    if (widget.post != null) {
      _txtControllerBody.text = widget.post!.body ?? '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title}'),
        backgroundColor: Colors.green,
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.green),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: _txtControllerBody,
                        keyboardType: TextInputType.multiline,
                        maxLines: 9,
                        validator: (val) =>
                            val!.isEmpty ? 'Post body is required' : null,
                        decoration: InputDecoration(
                          hintText: "Post body...",
                          contentPadding: EdgeInsets.all(8),
                          border: InputBorder.none, // Remove the default border
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  child: kTextButton('Post', () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _loading = !_loading;
                      });
                      if (widget.post == null) {
                        _createPost();
                      } else {
                        _editPost(widget.post!.id ?? 0);
                      }
                    }
                  }, icon: Icons.send, color: Colors.green),
                )
              ],
            ),
    );
  }
}
