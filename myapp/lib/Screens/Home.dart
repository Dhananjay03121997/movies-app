import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easy_debounce/easy_debounce.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  var moviesList, response, errorMessage;
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    try {
      response = await http.get(
          Uri.parse("https://imdb-api.com/en/API/Top250Movies/k_e3z93my9"));
      if (response.statusCode == 200) {
        moviesList = jsonDecode(response.body)['items'];
      } else {
        errorMessage = jsonDecode(response.body)['errorMessage'];
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Something went wrong");
    }
    setState(() {});
  }

  void searchData(val) async {
    try {
      response = await http
          .get(Uri.parse("https://imdb-api.com/en/API/Search/k_e3z93my9/$val"));
      if (response.statusCode == 200) {
        moviesList = jsonDecode(response.body)['results'];
      } else {
        errorMessage = jsonDecode(response.body)['errorMessage'];
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Something Went Wrong");
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffFFFFFF),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text(
            "Home",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: new Container(
            margin: EdgeInsets.only(left: 15, right: 15),
            child: new Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    onChanged: (val) => {
                      EasyDebounce.debounce(
                          'my-debouncer', Duration(milliseconds: 500), () {
                        if (val == "" || val == null) {
                          getData();
                        } else {
                          searchData(val);
                        }
                      })
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.zero)),
                        hintText: "Search for movies",
                        suffix: Icon(Icons.search)),
                  ),
                ),
                Expanded(
                    child: moviesList == null && errorMessage == null
                        ? new Center(
                            child: CircularProgressIndicator(),
                          )
                        : errorMessage != null
                            ? Center(child: Text("$errorMessage"))
                            : RefreshIndicator(
                                child: SingleChildScrollView(
                                  physics: ScrollPhysics(),
                                  child: Column(
                                    children: [
                                      ListView.builder(
                                          shrinkWrap: true,
                                          controller: ScrollController(),
                                          itemCount: moviesList.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Container(
                                              padding: EdgeInsets.all(6),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Image.network(
                                                    moviesList[index]['image'],
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            4,
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              3,
                                                          child: Text(
                                                            moviesList[index]
                                                                ['title'],
                                                            softWrap: true,
                                                          )),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 1,
                                                                bottom: 1,
                                                                left: 5,
                                                                right: 5),
                                                        decoration: BoxDecoration(
                                                            color: Colors.green,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10))),
                                                        child: moviesList[index]
                                                                    [
                                                                    'imDbRating'] !=
                                                                null
                                                            ? Text(
                                                                "${moviesList[index]['imDbRating']} IMDB")
                                                            : Text(""),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                              margin:
                                                  EdgeInsets.only(bottom: 10),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                  boxShadow: [
                                                    new BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.2),
                                                      offset: const Offset(
                                                        0,
                                                        1,
                                                      ),
                                                      blurRadius: 15.0,
                                                      spreadRadius: 2.0,
                                                    )
                                                  ]),
                                            );

                                            //  ListTile(
                                            //   leading: Image.network(moviesList[index]['image']),
                                            // );
                                          })
                                    ],
                                  ),
                                ),
                                onRefresh: () {
                                  return Future.delayed(
                                      Duration(seconds: 1), getData);
                                },
                              ))
              ],
            )));
  }
}
