import 'package:flutter/material.dart';
import 'package:pets/common/color_extension.dart';
import 'package:readmore/readmore.dart';

class UserReviewRow extends StatelessWidget {
  final bool isBottomActionBar;
  final VoidCallback? onCommentPress;
  final VoidCallback? onLikePress;
  final VoidCallback? onSharePress;
  late bool megusta;

  UserReviewRow(
      {super.key,
      this.isBottomActionBar = false,
      this.onSharePress,
      this.onLikePress,
      this.onCommentPress,
      this.megusta = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset(
                  'assets/img/u1.png',
                  width: 50,
                  height: 50,
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //TO DO nombre del usuario
                    Text(
                      "Hibe Neted",
                      style: TextStyle(
                          color: TColor.text,
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          const SizedBox(
            height: 8,
          ),
          ReadMoreText(
            'I enjoyed the food of the restaurant. The dishes are attractive and very beautiful. Good food, luxurious space and enthusiastic service. I will be back in the… I enjoyed the food of the restaurant. The dishes are attractive and very beautiful. Good food, luxurious space and enthusiastic service. I will be back in the…',
            trimLines: 4,
            colorClickableText: TColor.text,
            trimMode: TrimMode.Line,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: TColor.text),
            trimCollapsedText: 'Read more',
            trimExpandedText: 'Read less',
            moreStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: TColor.primary),
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  megusta = !megusta;
                  print("555555555555555555555555");
                },
                icon: Image.asset(
                  "assets/img/likeDisable.png",
                  width: 22,
                  height: 22,
                  fit: BoxFit.fitWidth,
                ),
              ),
              IconButton(
                onPressed: () {
                  if (onCommentPress != null) {
                    onCommentPress!();
                  }
                },
                icon: Image.asset(
                  "assets/img/comments.png",
                  width: 22,
                  height: 22,
                  fit: BoxFit.fitWidth,
                ),
              ),
              IconButton(
                onPressed: () {
                  if (onSharePress != null) {
                    onSharePress!();
                  }
                },
                icon: Image.asset(
                  "assets/img/share.png",
                  width: 22,
                  height: 22,
                  fit: BoxFit.fitWidth,
                ),
              ),
              const Spacer(),
              Text(
                "4 Likes",
                style: TextStyle(
                    color: TColor.gray,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                "3 Comments",
                style: TextStyle(
                    color: TColor.gray,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ],
          )
        ],
      ),
    );
  }
}
