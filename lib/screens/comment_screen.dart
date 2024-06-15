import 'package:flutter_app/models/api_response.dart';
import 'package:flutter_app/models/comment.dart';
import 'package:flutter_app/services/comment_service.dart';
import 'package:flutter_app/services/user_service.dart';
import 'package:flutter/material.dart';

import '../constant.dart';
import 'login.dart';

class CommentScreen extends StatefulWidget {
  final int? postId;

  CommentScreen({this.postId});

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  List<dynamic> _commentsList = [];
  bool _loading = true;
  int userId = 0;
  int _editCommentId = 0;
  TextEditingController _txtCommentController = TextEditingController();

  // Get comments
  Future<void> _getComments() async {
    userId = await getUserId();
    ApiResponse response = await getComments(widget.postId ?? 0);

    if (response.error == null) {
      setState(() {
        _commentsList = response.data as List<dynamic>;
        _loading = _loading ? !_loading : _loading;
      });
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  // create comment
  void _createComment() async {
    ApiResponse response =
        await createComment(widget.postId ?? 0, _txtCommentController.text);

    if (response.error == null) {
      _txtCommentController.clear();
      _getComments();
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    } else {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  // edit comment
  void _editComment() async {
    ApiResponse response =
        await editComment(_editCommentId, _txtCommentController.text);

    if (response.error == null) {
      _editCommentId = 0;
      _txtCommentController.clear();
      _getComments();
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  // Delete comment
  void _deleteComment(int commentId) async {
    ApiResponse response = await deleteComment(commentId);

    if (response.error == null) {
      _getComments();
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  @override
  void initState() {
    _getComments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
        backgroundColor: Colors.green,
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(children: [
              Expanded(
                  child: RefreshIndicator(
                      onRefresh: () {
                        return _getComments();
                      },
                      child: ListView.builder(
                          itemCount: _commentsList.length,
                          itemBuilder: (BuildContext context, int index) {
                            Comment comment = _commentsList[index];
                            return Container(
                              padding: EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.black26, width: 0.5))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${comment.user!.name}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16),
                                      ),
                                      comment.user!.id == userId
                                          ? PopupMenuButton(
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(right: 10),
                                                child: Icon(
                                                  Icons.more_vert,
                                                  color: Colors
                                                      .green, // Change the color here
                                                ),
                                              ),
                                              itemBuilder: (context) => [
                                                PopupMenuItem(
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.edit,
                                                          color: Colors
                                                              .green), // Change the color and icon here
                                                      SizedBox(width: 8),
                                                      Text(''),
                                                    ],
                                                  ),
                                                  value: 'edit',
                                                ),
                                                PopupMenuItem(
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.delete,
                                                          color: Colors
                                                              .red), // Change the color and icon here
                                                      SizedBox(width: 8),
                                                      Text(''),
                                                    ],
                                                  ),
                                                  value: 'delete',
                                                ),
                                              ],
                                              onSelected: (val) {
                                                if (val == 'edit') {
                                                  setState(() {
                                                    _editCommentId =
                                                        comment.id ?? 0;
                                                    _txtCommentController.text =
                                                        comment.comment ?? '';
                                                  });
                                                } else {
                                                  _deleteComment(
                                                      comment.id ?? 0);
                                                }
                                              },
                                            )
                                          : SizedBox()
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('${comment.comment}')
                                ],
                              ),
                            );
                          }))),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Colors.black26, width: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width *
                          0.8, // Set a width
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Comment',
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          border: InputBorder.none,
                        ),
                        controller: _txtCommentController,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.comment,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        if (_txtCommentController.text.isNotEmpty) {
                          setState(() {
                            _loading = true;
                          });
                          if (_editCommentId > 0) {
                            _editComment();
                          } else {
                            _createComment();
                          }
                        }
                      },
                    )
                  ],
                ),
              )
            ]),
    );
  }
}
