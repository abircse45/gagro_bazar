import 'package:flutter/material.dart';

import 'package:smooth_star_rating/smooth_star_rating.dart';

import 'category_page2.dart';
import 'category_subcategory.dart';

class Page1 extends StatelessWidget {
  Page1(this.childList);

  List<Child> childList;
  bool isFavorite = false;
  var rating = 1.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 15.0,
          childAspectRatio: 0.8,
        ),
        itemCount: childList.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding:
                EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0, right: 5.0),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3.0,
                        blurRadius: 5.0)
                  ],
                  color: Colors.white),
              child: Column(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(0.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            isFavorite
                                ? Icon(Icons.favorite,
                                    size: 25, color: Color(0xFFEF7532))
                                : Icon(Icons.favorite_border,
                                    size: 25, color: Color(0xFFEF7532))
                          ])),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Page2(childList[index].child)),
                      );
                    },
                    child: Image.network(
                      childList[index].image,
                      height: 100,
                      width: 100,
                    ),
                  ),
                  SmoothStarRating(
                      allowHalfRating: false,
                      onRated: (v) {},
                      starCount: 5,
                      size: 20.0,
                      rating: rating,
                      isReadOnly: false,
                      filledIconData: Icons.star,
                      halfFilledIconData: Icons.star_half,
                      defaultIconData: Icons.star_border,
                      color: Colors.red,
                      borderColor: Colors.red,
                      spacing: 0.0),
                  SizedBox(height: 5.0),
                  Text("${childList[index].name}",
                      style: TextStyle(
                          color: Color(0xFF575E67),
                          fontFamily: 'Varela',
                          fontSize: 20.0)),
                ],
              ),
            ),
          );
        },
      ),
    ));
  }
}
//
//ListTile(
//contentPadding: EdgeInsets.all(6.0),
//title: Text("${childList[index].name}"),
//leading: Image.network(childList[index].image),
//onTap: () {
//Navigator.push(
//context,
//MaterialPageRoute(
//builder: (context) => Page2(childList[index].child)),
//);
//},
//);
