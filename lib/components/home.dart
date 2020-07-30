import 'package:dio/dio.dart';
/**
 * Author: Damodar Lohani
 * profile: https://github.com/lohanidamodar
  */

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:txa/components/login.dart';
import 'package:txa/utils/baseurl.dart';

class Home extends StatefulWidget {
  static final String path = "lib/src/pages/dashboard/dash3.dart";

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final String avatar =
      'https://firebasestorage.googleapis.com/v0/b/dl-flutter-ui-challenges.appspot.com/o/img%2F1.jpg?alt=media';

  final TextStyle whiteText = TextStyle(color: Colors.white);
  String profileImage = '';
  String fullname = '';
  String username = '';
  String token = '';
  int batch = 0;
  int totalQuizToday = 0;
  int totalQuiz = 0;
  int totalContent = 0;
  int totalScore = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    getToken();
    getTotalQuiz();
    totalQuizByBatch();
    upcomingContent();
    quizDone();
    print(token);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      profileImage = prefs.getString('profile');
    });
  }

  Future upcomingContent() async {
    Dio dio = Dio();
    dio.get(baseurl('/content/upcoming')).then((value) {
      setState(() {
        totalContent = value.data;
        //username = value.data['username'];
      });
    }).catchError((onError) {
      print(onError);
    });
  }

  Future quizDone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');
    Dio dio = Dio();
    dio.post(baseurl('/score/total'), data: {"userId": userId}).then((value) {
      setState(() {
        totalScore = value.data;
        //username = value.data['username'];
      });
    }).catchError((onError) {
      print(onError);
    });
  }

  Future totalQuizByBatch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int batchz = prefs.getInt('batch');
    print('batch');
    print(batchz);
    setState(() {
      batch = batchz;
    });
    Dio dio = Dio();
    dio.post(baseurl('/category/total-batch'), data: {"batch": batchz}).then(
        (value) {
      setState(() {
        totalQuiz = value.data;
        //username = value.data['username'];
      });
    }).catchError((onError) {
      print(onError);
    });
  }

  Future getTotalQuiz() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int batchz = prefs.getInt('batch');
    setState(() {
      batch = batchz;
    });
    Dio dio = Dio();
    dio.post(baseurl('/category/batch'), data: {"batch": batchz}).then((value) {
      setState(() {
        totalQuizToday = value.data;
        //username = value.data['username'];
      });
    }).catchError((onError) {
      print(onError);
    });
  }

  Future getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    Dio dio = Dio();
    dio.post(baseurl('/user'), data: {"token": token}).then((value) {
      if (value.data['code'] == 209) {
        prefs.setString('login', 'false');
        return Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => Login()), (_) => false);
      }
      setState(() {
        fullname = value.data['fullname'];
        username = value.data['username'];
      });
    }).catchError((onError) {
      print(onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildBody(context),
      //bottomNavigationBar: _buildBottomBar(),
    );
  }

  Future<String> _getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile');
  }

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.grey.shade800,
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      onTap: (i) {},
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text("Home"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_add),
          title: Text("Refer"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          title: Text("History"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          title: Text("Profile"),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildHeader(),
          const SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              "Data user",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
          ),
          Card(
            elevation: 4.0,
            color: Colors.white,
            margin: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ListTile(
                    leading: Container(
                      alignment: Alignment.bottomCenter,
                      width: 45.0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            height: 20,
                            width: 8.0,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 4.0),
                          Container(
                            height: 25,
                            width: 8.0,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 4.0),
                          Container(
                            height: 40,
                            width: 8.0,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4.0),
                          Container(
                            height: 30,
                            width: 8.0,
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),
                    title: Text("Quiz slnjtny"),
                    subtitle: Text(totalQuizToday.toString() + ' quiz'),
                  ),
                ),
                VerticalDivider(),
                Expanded(
                  child: ListTile(
                    leading: Container(
                      alignment: Alignment.bottomCenter,
                      width: 45.0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            height: 20,
                            width: 8.0,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 4.0),
                          Container(
                            height: 25,
                            width: 8.0,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 4.0),
                          Container(
                            height: 40,
                            width: 8.0,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4.0),
                          Container(
                            height: 30,
                            width: 8.0,
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),
                    title: Text("Total Quiz"),
                    subtitle: Text(totalQuiz.toString() + ' quiz'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: _buildTile(
                    color: Colors.pink,
                    icon: Icons.portrait,
                    title: "Total quiz dikerjakan",
                    data: totalScore.toString(),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: _buildTile(
                    color: Colors.green,
                    icon: Icons.portrait,
                    title: "Event",
                    data: totalContent.toString(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _buildTile(
                    color: Colors.blue,
                    icon: Icons.favorite,
                    title: "Kehadiran",
                    data: "864",
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: _buildTile(
                    color: Colors.pink,
                    icon: Icons.portrait,
                    title: "Absen",
                    data: "Done",
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }

  Container _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 50.0, 0, 32.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
        color: Colors.blue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(
              "Dashboard",
              style: whiteText.copyWith(
                  fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            trailing: CircleAvatar(
              radius: 25.0,
              backgroundImage: CachedNetworkImageProvider(profileImage),
            ),
          ),
          const SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              fullname,
              style: whiteText.copyWith(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 5.0),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              username + '-batch$batch',
              style: whiteText,
            ),
          ),
        ],
      ),
    );
  }

  Container _buildTile(
      {Color color, IconData icon, String title, String data}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      height: 150.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Icon(
            icon,
            color: Colors.white,
          ),
          Text(
            title,
            style: whiteText.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            data,
            style:
                whiteText.copyWith(fontWeight: FontWeight.bold, fontSize: 20.0),
          ),
        ],
      ),
    );
  }
}
