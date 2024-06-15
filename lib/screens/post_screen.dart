import 'package:flutter_app/constant.dart';
import 'package:flutter_app/models/api_response.dart';
import 'package:flutter_app/models/post.dart';
import 'package:flutter_app/screens/comment_screen.dart';
import 'package:flutter_app/services/post_service.dart';
import 'package:flutter_app/services/user_service.dart';
import 'package:flutter/material.dart';

import 'login.dart';
import 'post_form.dart';

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<dynamic> _postList = [];
  int userId = 0;
  bool _loading = true;

  // get all posts
  Future<void> retrievePosts() async {
    userId = await getUserId();
    ApiResponse response = await getPosts();

    if (response.error == null) {
      setState(() {
        _postList = response.data as List<dynamic>;
        _loading = _loading ? !_loading : _loading;
      });
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${response.error}'),
      ));
    }
  }

  void _handleDeletePost(int postId) async {
    ApiResponse response = await deletePost(postId);
    if (response.error == null) {
      retrievePosts();
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

  // post like dislike
  void _handlePostLikeDislike(int postId) async {
    ApiResponse response = await likeUnlikePost(postId);

    if (response.error == null) {
      retrievePosts();
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
    retrievePosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () {
              return retrievePosts();
            },
            child: ListView.builder(
                itemCount: _postList.length,
                itemBuilder: (BuildContext context, int index) {
                  Post post = _postList[index];
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Row(
                                children: [
                                  // Removed image container here
                                  Text(
                                    '${post.user!.name}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 17),
                                  )
                                ],
                              ),
                            ),
                            post.user!.id == userId
                                ? PopupMenuButton(
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Icon(
                                        Icons.more_vert,
                                        color: Colors.green,
                                      ),
                                    ),
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit,
                                                color: Colors
                                                    .green), // Add icon here
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
                                                    .red), // Add icon here
                                            SizedBox(width: 8),
                                            Text(''),
                                          ],
                                        ),
                                        value: 'delete',
                                      ),
                                    ],
                                    onSelected: (val) {
                                      if (val == 'edit') {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) => PostForm(
                                                      title: 'Edit Post',
                                                      post: post,
                                                    )));
                                      } else {
                                        _handleDeletePost(post.id ?? 0);
                                      }
                                    },
                                  )
                                : SizedBox()
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text('${post.body}'),
                        // Removed post image container here
                        Row(
                          children: [
                            kLikeAndComment(
                                post.likesCount ?? 0,
                                post.selfLiked == true
                                    ? Icons.star
                                    : Icons.star_border_outlined,
                                post.selfLiked == true
                                    ? Colors.yellow
                                    : Colors.lightGreen, () {
                              _handlePostLikeDislike(post.id ?? 0);
                            }),
                            Container(
                              height: 25,
                              width: 0.5,
                              color: Colors.black38,
                            ),
                            kLikeAndComment(post.commentsCount ?? 0,
                                Icons.message, Colors.lightGreen, () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => CommentScreen(
                                        postId: post.id,
                                      )));
                            }),
                          ],
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 0.5,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  );
                }),
          );
  }
}
