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

class AllProductScreen extends StatefulWidget {
  @override
  _AllProductScreenState createState() => _AllProductScreenState();
}

class _AllProductScreenState extends State<AllProductScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isFavorite = false;

  Future<Catalog> fetchGagro() async {
    final response = await http.get(
        'http://uat.gagro.com.bd/api/product-data'); // ?fbclid=IwAR1vj83qPGT3nu-fT8OFT5CU5N3pZOWspDVSrRvU7Q2H-pRB6oIHP2bWkOk

    if (response.statusCode == 200) {
      return Catalog.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load album');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        title: Text(
          'Product',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 30,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: FutureBuilder(
                      future: fetchGagro(),
                      builder: (BuildContext context,
                          AsyncSnapshot<Catalog> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(
                            "",
                            style: TextStyle(
                              color: Colors.black87,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w400,
                            ),
                          );
                        } else {
                          final dataList = snapshot.data.data.dataList;
                          var totalProduct = dataList.length;
                          debugPrint("$totalProduct");
                          return Text(
                            "$totalProduct Products found",
                            style: TextStyle(
                              color: Colors.black87,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w400,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 120,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              height: MediaQuery.of(context).size.height - 130,
              child: _productScreenTile(),
            )
          ],
        ),
      ),
    );
  }

  Widget _productScreenTile() {
    return FutureBuilder(
      future: fetchGagro(),
      builder: (BuildContext context, AsyncSnapshot<Catalog> snapshot) {
        if (snapshot.hasData) {
          final dataList = snapshot.data.data.dataList;

          return GridView.builder(
            scrollDirection: Axis.vertical,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
            ),
            itemCount: dataList.length,
            itemBuilder: (context, index) {
              return ProductScreenTile(
                productObject: dataList[index],
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
    );
  }
}

class ProductScreenTile extends StatefulWidget {
  final DataList productObject;
  ProductScreenTile({Key key, this.productObject}) : super(key: key);

  @override
  _ProductScreenTileState createState() => _ProductScreenTileState();
}

class _ProductScreenTileState extends State<ProductScreenTile> {
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

  bool _addToCartClicked = false;

  int _counter = 5;

  void _increaseCartItem(int productId, int quantity) {
    setState(() {
      _counter++;
      addToCart(productId, _counter);
    });

    debugPrint("$_counter");
  }

  void _decreaseCartItem(int productId, int quantity) {
    if (_counter <= 5) {
      final snackBar = SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("Minimum product order is 5"),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    } else {
      setState(() {
        _counter--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProductDetailsScreen(
                        productObject: widget.productObject,
                      )));
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: 190,
          decoration: BoxDecoration(
            color: white,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey[300], offset: Offset(1, 1), blurRadius: 4),
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
                        imageUrl: widget.productObject.image1,
                        height: 100,
                        width: 100,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Positioned(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  "${widget.productObject.name}",
                  style: TextStyle(
                      fontSize: widget.productObject.name.length < 20 ? 20 : 15,
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
                        widget.productObject.price != null
                            ? "৳ ${widget.productObject.price}"
                            : "",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black38,
                          decoration: TextDecoration.lineThrough,
                          decorationStyle: TextDecorationStyle.solid,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 5),
                      child: Text("৳ ${widget.productObject.originalPrice}",
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                    ),
                  ],
                ),
              ),
              _addToCartClicked
                  ? Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => _decreaseCartItem(
                                widget.productObject.id, _counter),
                            child: Icon(
                              Icons.remove_circle,
                              color: Colors.redAccent,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "$_counter",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () => _increaseCartItem(
                                widget.productObject.id, _counter),
                            child:
                                Icon(Icons.add_circle, color: Colors.redAccent),
                          ),
                          SizedBox(
                            width: 25,
                          )
                        ],
                      ),
                    )
                  : Container(
                      height: 25,
                      width: 100,
                      child: RaisedButton(
                        color: Colors.redAccent,
                        shape: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onPressed: () {
                          addToCart(widget.productObject.id, _counter);
                          setState(() {
                            _addToCartClicked = true;
                          });
                        },
                        child: Text(
                          "+ ADD",
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
  }
}
