import 'package:flutter/material.dart';
import 'package:pets/pages/home/comment_list_view.dart';
import 'package:pets/pages/home/like_user_list_view.dart';
import 'package:pets/pages/forum/my_review_comment_view.dart';

import '../../common/color_extension.dart';
import '../../common_widget/popup_layout.dart';
import '../../common_widget/selection_button.dart';
import '../../common_widget/user_review_row.dart';

class ForumPage extends StatefulWidget {
  ForumPage({super.key});

  @override
  ForumPageState createState() => ForumPageState();
}

class ForumPageState extends State<ForumPage> {

  var selectTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              pinned: true,
              floating: false,
              centerTitle: false,
              leadingWidth: 0,
              title: Row(
                children: [
                  const SizedBox(
                    width: 8,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Forum",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: TColor.text,
                            fontSize: 24,
                            fontWeight: FontWeight.w700),
                      ),
                      Text(
                        "Pets",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: TColor.gray,
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ];
        },
        body: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 2),
            itemCount: 6,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyReviewCommentView()));
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 1,  offset: Offset(0, 1))
                      ]),
                  child:  UserReviewRow(
                    isBottomActionBar: true,
                    onCommentPress: (){
                       Navigator.push(
                          context, PopupLayout(child: const CommentListView()));
                    },
                    onLikePress: () {
                        
                    },
                  ),
                ),
              );
            }),
      ),
    );
  }


}
