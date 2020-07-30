import 'package:dio/dio.dart';
/**
 * Author: Damodar Lohani
 * profile: https://github.com/lohanidamodar
  */

import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:txa/components/quizpage.dart';
import 'package:txa/components/quiztimer.dart';
import 'package:txa/utils/baseurl.dart';
import 'category.dart';

class QuizHomePage extends StatefulWidget {
  static final String path = "lib/src/pages/quiz_app/home.dart";

  @override
  _QuizHomePageState createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizHomePage> {
  final List<Color> tileColors = [
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.indigo,
    Colors.lightBlue,
    Colors.amber,
    Colors.deepOrange,
    Colors.red,
    Colors.brown
  ];

  List categories = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCategory();
  }

  Future getCategory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int batch = prefs.getInt('batch');

    Dio dio = Dio();
    dio.post(baseurl('/category/list-batch'), data: {"batch": batch}).then(
        (value) {
      setState(() {
        categories = value.data;
      });
    }).catchError((onError) {
      print(onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Text('Pilih Category'),
          elevation: 0,
        ),
        body: Stack(
          children: <Widget>[
            ClipPath(
              clipper: WaveClipperTwo(),
              child: Container(
                decoration: BoxDecoration(color: Colors.deepPurple),
                height: 200,
              ),
            ),
            CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 20),
                    child: Text(
                      "Pilih category untuk memulai quiz",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16.0),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0),
                      delegate: SliverChildBuilderDelegate(
                        _buildCategoryItem,
                        childCount: categories.length,
                      )),
                ),
              ],
            ),
          ],
        ));
  }

  Widget _buildCategoryItem(BuildContext context, int index) {
    var categoryx = categories[index];
    return MaterialButton(
      elevation: 1.0,
      highlightElevation: 1.0,
      onPressed: () {
        print('objectId');
        print(categoryx['objectId']);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => QuizPage(
                      objectId: categoryx['objectId'],
                      times: categoryx['timeInMinutes'],
                      quizTitle: categoryx['category'],
                    )));
        //Navigator.of(context).pop(categoryx['objectId']);
        //Navigator
        //_categoryPressed(context, categoryx);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: Colors.grey.shade800,
      textColor: Colors.white70,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(FontAwesomeIcons.globeAsia),
          SizedBox(height: 5.0),
          Text(
            categoryx['category'],
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  // _categoryPressed(BuildContext context, Category category) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (sheetContext) => BottomSheet(
  //       builder: (_) => QuizOptionsDialog(
  //         category: category,
  //       ),
  //       onClosing: () {},
  //     ),
  //   );
  // }
}
