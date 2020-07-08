import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gagro/model/product_list_model.dart';
import 'package:gagro/screen/product_description.dart';
import 'package:gagro/utils/constant.dart';
import 'package:http/http.dart' as http;

class Search extends StatefulWidget {
  String vals;
  Search(String val) {
    vals = val;
  }
  @override
  _Search createState() => _Search(vals);
}

class _Search extends State<Search> {
  bool isFavorite = false;
  TextEditingController _searchingController = TextEditingController();
  String _searching;
  _Search(String val) {
    _searchingController.text = val;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        title: Text(
          'Search Result',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 30,
              color: Colors.white,
              child: ListTile(
                leading: Icon(
                  Icons.search,
                  color: red,
                ),
                title: TextFormField(
                  autofocus: true,
                  controller: _searchingController,
                  onChanged: (val) {
                    setState(() {
                      _searching = val.trim();
                    });
                  },
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: "Search  product.."),
                ),
                trailing: Icon(
                  Icons.filter_list,
                  color: red,
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              height: MediaQuery.of(context).size.height,
              child: _productScreenTile(),
            )
          ],
        ),
      ),
    );
  }

  Widget _productScreenTile() {
    return FutureBuilder(
      future: fetchGagro(_searching.toString()),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      Icons.radio_button_checked,
                                      size: 20,
                                      color:
                                          dataList[index].remainingProduct < 1
                                              ? Colors.red
                                              : Colors.green,
                                    ),
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
                                fontSize:
                                    dataList[index].name.length < 20 ? 20 : 15,
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
                                    decorationStyle: TextDecorationStyle.solid,
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
                        Container(
                          height: 25,
                          width: 100,
                          child: RaisedButton(
                            color: Colors.redAccent,
                            shape: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.redAccent),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onPressed: () {},
                            child: Text(
                              "+ ADD",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.center,
                          child: Text(
                            "Standard Delivery",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
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
    );
  }
}

Future<Catalog> fetchGagro(String search) async {
  final response = await http.get('http://uat.gagro.com.bd/api/products/search/' +
      search); // ?fbclid=IwAR1vj83qPGT3nu-fT8OFT5CU5N3pZOWspDVSrRvU7Q2H-pRB6oIHP2bWkOk

  if (response.statusCode == 200) {
    return Catalog.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load album');
  }
}
