import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gagro/model/product_list_model.dart';
import 'package:gagro/screen/product_description.dart';
import 'package:gagro/utils/constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  bool isFavorite = false;

  Future addToCart(int productId, int quantity) async {
    SharedPreferences _preference = await SharedPreferences.getInstance();
    String token = _preference.getString('token');
    var response =
        await http.post("http://uat.gagro.com.bd/api/cart", headers: {
      "Accept": "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    }, body: {
      "product_id": productId.toString(),
      "quantity": quantity.toString(),
    });

    final addCartdata = json.decode(response.body);
    print(addCartdata);

    bool success = addCartdata["Success"];

    if (success == true) {
      Fluttertoast.showToast(
          msg: "Added product Successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.greenAccent,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "error occoured :(",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: FutureBuilder(
        future: fetchGagro(),
        builder: (BuildContext context, AsyncSnapshot<Catalog> snapshot) {
          if (snapshot.hasData) {
            final dataList = snapshot.data.data.dataList;
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProductDetailsScreen(
                                    productObject: dataList[index],
                                  )));
                      debugPrint('$dataList[index]');
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: 190,
                      decoration: BoxDecoration(
                        color: white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey[300],
                              offset: Offset(1, 1),
                              blurRadius: 4),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.zero,
                                  margin: EdgeInsets.only(left: 30),
                                  child: CachedNetworkImage(
                                    imageUrl: dataList[index].image1,
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              Positioned(
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "500gm",
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w600),
                                        softWrap: true,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 40,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: Text(
                              "${dataList[index].name}",
                              style: TextStyle(
                                  fontSize: dataList[index].name.length < 20
                                      ? 20
                                      : 15,
                                  fontWeight: FontWeight.w500,
                                  height: 1,
                                  fontFamily: 'Bengali'),
                              softWrap: true,
                            ),
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  child: Text(
                                    dataList[index].price != null
                                        ? "৳ ${dataList[index].price}"
                                        : "",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black38,
                                      decoration: TextDecoration.lineThrough,
                                      decorationStyle:
                                          TextDecorationStyle.solid,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Text(
                                      "৳ ${dataList[index].originalPrice}",
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                            height: 25,
                            width: 100,
                            child: RaisedButton(
                              color: Colors.redAccent,
                              shape: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.redAccent),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              onPressed: () {
                                addToCart(dataList[index].id,
                                    dataList[index].quantity);
                              },
                              child: Text(
                                "+   ADD  - ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            print(snapshot.error);
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.purple),
              ),
            );
          }
        },
      ),
    );
  }
}

Future<Catalog> fetchGagro() async {
  final response = await http.get(
      'http://uat.gagro.com.bd/api/product-data'); // ?fbclid=IwAR1vj83qPGT3nu-fT8OFT5CU5N3pZOWspDVSrRvU7Q2H-pRB6oIHP2bWkOk

  try {
    if (response.statusCode == 200) {
      return Catalog.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load album');
    }
  } catch (e) {}
}
