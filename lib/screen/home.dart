import 'dart:convert';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gagro/Api/api.dart';
import 'package:gagro/screen/cart_screen.dart';
import 'package:gagro/screen/login.dart';
import 'package:gagro/screen/profile.dart';
import 'package:gagro/screen/search.dart';
import 'package:gagro/utils/constant.dart';
import 'package:gagro/widget/category_subcategory.dart';
import 'package:gagro/widget/custom_drawer.dart';
import 'package:gagro/widget/page1.dart';
import 'package:gagro/widget/product_list.dart';
import 'package:gagro/widget/product_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Api/api.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int pageIndex = 0;

  final HomeScreen _homeScreen = HomeScreen();
  final CartPage _cartPage = CartPage();
  final AllProductScreen _allProductScreen = AllProductScreen();
  final ProfileGet _profileGet = ProfileGet();

  Widget _showPage = HomeScreen();

  Widget _pageController(int page) {
    switch (page) {
      case 0:
        return _homeScreen;
        break;
      case 1:
        return _cartPage;
        break;
      case 2:
        return _allProductScreen;
        break;
      case 3:
        return _profileGet;
        break;

      default:
        return _homeScreen;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.cyan,
        backgroundColor: Colors.white24,
        buttonBackgroundColor: Colors.cyan,
        height: 50,
        animationDuration: Duration(milliseconds: 400),
        index: 0,
        items: <Widget>[
          Icon(
            Icons.home,
            size: 25,
            color: Colors.white,
          ),
          Icon(
            Icons.shopping_cart,
            size: 25,
            color: Colors.white,
          ),
          Icon(
            Icons.list,
            size: 25,
            color: Colors.white,
          ),
          Icon(
            FontAwesomeIcons.user,
            size: 25,
            color: Colors.white,
          ),
        ],
        onTap: (int index) {
          setState(() {
            _showPage = _pageController(index);
          });
        },
      ),
      drawer: CustomDrawer(),
      body: _showPage,
    );
  }
}

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // Slider Widget

  Animation<double> animation;
  AnimationController controller;

  initState() {
    super.initState();
    controller = new AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    animation = new Tween(begin: 0.0, end: 18.0).animate(controller)
      ..addListener(() {
        setState(() {
          // the state that has changed here is the animation object’s value
        });
      });
    controller.forward();
  }

  // end

  bool isLoading = false;
  bool isSearching = false;
  TextEditingController _searchingController = TextEditingController();

  void signOut() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences _preference = await SharedPreferences.getInstance();
    String token = _preference.getString('token');
    debugPrint('token is: $token');
    final response = await http.get(BaseURL.logout).then((value) async {
      await _preference.clear();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Login()),
        (Route<dynamic> route) => false,
      );
      setState(() {
        isLoading = true;
      });
    });
    return response;
  }

  @override
  Widget build(BuildContext context) {
    Widget carousel = new Carousel(
      boxFit: BoxFit.cover,
      dotHorizontalPadding: 0,
      images: [
        new AssetImage('assets/images/image1.jpg'),
        new AssetImage('assets/images/image2.jpg'),
        new AssetImage('assets/images/image4.jpg'),
        new AssetImage('assets/images/image5.jpg'),
      ],
      dotColor: white,
      indicatorBgPadding: 0,
      dotIncreaseSize: 0,
      dotBgColor: white,
      animationCurve: Curves.fastOutSlowIn,
      animationDuration: Duration(seconds: 1),
    );

    return Scaffold(
      appBar: AppBar(
        title: !isSearching
            ? Text("")
            : TextFormField(
                controller: _searchingController,
                onChanged: (val) {
                  setState(() {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Search(val.trim())));

                    _searchingController.clear();
                  });
                },
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: "Search product")),
        iconTheme: new IconThemeData(color: Colors.grey[800]),
        actions: [
          isSearching
              ? IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      this.isSearching = false;
                    });
                  },
                )
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      this.isSearching = true;
                    });
                  },
                ),
          IconButton(
              icon: Icon(
                Icons.shopping_cart,
                size: 30,
                color: Colors.grey[800],
              ),
              onPressed: () {}),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      drawer: CustomDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: 210,
                padding: EdgeInsets.all(3),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Stack(
                    children: [carousel],
                  ),
                ),
              ),

              SizedBox(
                height: 10,
              ),

              Padding(
                padding: EdgeInsets.only(
                  right: 250,
                ),
                child: Text(
                  "Category",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),

              Container(
                height: 120,
                child: FutureBuilder(
                  future: fetchGagro(),
                  builder:
                      (BuildContext context, AsyncSnapshot<Gagro> snapshot) {
                    if (snapshot.hasData) {
                      final dataList = snapshot.data.data.dataList;
                      return Container(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: dataList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(35),
                                    child: Container(
                                      height: 55,
                                      width: 55,
                                      decoration: BoxDecoration(
                                        color: white,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey[300],
                                              offset: Offset(1, 1),
                                              blurRadius: 4),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(4),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => Page1(
                                                      dataList[index]
                                                          .childList)),
                                            );
                                          },
                                          child: Image.network(
                                            dataList[index].image,
                                            width: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    "${dataList[index].name}",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
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
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Product List",
                    style: TextStyle(fontSize: 20),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AllProductScreen()));
                    },
                    child: Text(
                      "See More",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),

              //  2nd part of widget product list widget,

              ProductList(),

              Padding(
                padding: EdgeInsets.only(bottom: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<Gagro> fetchGagro() async {
  final response = await http.get(
      'http://uat.gagro.com.bd/api/category-data'); // ?fbclid=IwAR1vj83qPGT3nu-fT8OFT5CU5N3pZOWspDVSrRvU7Q2H-pRB6oIHP2bWkOk

  try {
    if (response.statusCode == 200) {
      return Gagro.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load album');
    }
  } catch (e) {}
}
