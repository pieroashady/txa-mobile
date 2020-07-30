import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:txa/components/quizfinished.dart';
import 'package:txa/components/quiztimer.dart';
import 'package:txa/utils/baseurl.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

class QuizPage extends StatefulWidget {
  final String objectId;
  final String quizTitle;
  final int times;

  const QuizPage({Key key, this.objectId, this.quizTitle, this.times})
      : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final TextStyle _questionStyle = TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.white);
  int _currentIndex = 0;
  final Map<int, dynamic> _answers = {};
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  List quizList = [];
  List kunciJawaban;
  List userAnswers;
  String title;
  bool done = false;
  bool loading;
  bool alert;

  @override
  void initState() {
    // TODO: implement initState
    print(quizList.isEmpty);
    getQuiz();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getQuiz() async {
    setState(() {
      loading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');
    Dio dio = Dio();
    dio.post(baseurl('/score/check'),
        data: {"categoryId": widget.objectId, "userId": userId}).then((value) {
      if (value.data['status'] == 0) {
        print('belum dikerjakan');
        Dio dio = Dio();
        dio.post(baseurl('/quiz/category'),
            data: {"categoryId": widget.objectId}).then((value) {
          setState(() {
            quizList = value.data;
            kunciJawaban = value.data[0]['categoryId']['kunciJawaban'];
            title = value.data[0]['categoryId']['category'];

            loading = false;
          });
        }).catchError((err) {
          setState(() {
            loading = false;
            alert = true;
          });
        });
      } else {
        print('sudah dikerjakan');
        setState(() {
          loading = false;
          done = true;
        });
      }
    }).catchError((onError) {
      setState(() {
        loading = false;
        alert = true;
      });
      print(onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    //Question question = widget.questions[_currentIndex];
    //final List<dynamic> options = question.incorrectAnswers;
    // if(!options.contains(question.correctAnswer)) {
    //   options.add(question.correctAnswer);
    //   options.shuffle();
    // }
    if (loading) {
      return Container(
        color: Colors.white,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (!done) {
      if (quizList.isEmpty) {
        return Scaffold(
          key: _key,
          appBar: AppBar(
            backgroundColor: Colors.deepPurple,
            title: Text('Perhatian'),
            elevation: 0,
          ),
          body: Container(
            child: Center(
              child: AlertDialog(
                content: Text("Soal belum ada"),
                title: Text("Warning!"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Confirm"),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          key: _key,
          appBar: AppBar(
            backgroundColor: Colors.deepPurple,
            title: Text(widget.quizTitle ?? ""),
            elevation: 0,
          ),
          body: Stack(
            children: <Widget>[
              ClipPath(
                clipper: WaveClipperTwo(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                  ),
                  height: 200,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: <Widget>[
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.white70,
                        child: Text("${_currentIndex + 1}"),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: Text(
                          // quizList?.elementAt(0) ?? ""
                          quizList?.elementAt(_currentIndex)['question'] ?? "",
                          // widget.questions[_currentIndex].question,
                          softWrap: true,
                          style: _questionStyle,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CountDownTimer(
                          secondsRemaining: (widget.times * 60) + 2,
                          whenTimeExpires: () {
                            _saveData();
                            // setState(() {
                            //   hasTimerStopped = true;
                            // });
                          },
                          countDownTimerStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 17.0,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ...quizList[_currentIndex]['answers']
                            .asMap()
                            .entries
                            .map(
                              (option) => RadioListTile(
                                title: Text(option.value),
                                groupValue: _answers[_currentIndex],
                                value: option.key,
                                onChanged: (value) {
                                  print(value);
                                  setState(
                                    () {
                                      _answers[_currentIndex] = value;
                                      //userAnswers[_currentIndex] = value;
                                    },
                                  );
                                  print(userAnswers);
                                  print(_answers);
                                },
                              ),
                            ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        child: Text(_currentIndex == (quizList.length - 1)
                            ? "Submit"
                            : "Next"),
                        onPressed: () {
                          Center(
                            child: CircularProgressIndicator(),
                          );
                          _nextSubmit();
                        },
                      ),
                    ),
                  ),
                ]),
              )
            ],
          ),
        ),
      );
    } else if (done) {
      return Scaffold(
          key: _key,
          appBar: AppBar(
            backgroundColor: Colors.deepPurple,
            title: Text('Perhatian'),
            elevation: 0,
          ),
          body: Container(
            child: Center(
              child: AlertDialog(
                content: Text("Quiz sudah dikerjakan"),
                title: Text("Warning!"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Confirm"),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                  ),
                ],
              ),
            ),
          ));
    } else if (alert) {
      return Scaffold(
        key: _key,
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Text('Perhatian'),
          elevation: 0,
        ),
        body: Container(
          child: Center(
            child: AlertDialog(
              content: Text("Something went wrong"),
              title: Text("Warning!"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Confirm"),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future _saveData() async {
    int correct = 0;
    List list = [];
    _answers.forEach((key, value) {
      if (quizList[key]['correctAnswers'] == value) correct++;
    });
    _answers.forEach((key, value) => list.add(value));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');
    Dio dio = Dio();
    var data = {
      "totalScore":
          num.parse((correct / quizList.length * 100).toStringAsFixed(1)),
      "userAnswers": list,
      "categoryId": widget.objectId,
      "userId": userId,
      "passed": correct / quizList.length * 100 > 75 ? true : false
    };
    dio.post(baseurl('/score/add'), data: data).then((value) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => QuizFinishedPage(
                questions: quizList,
                answers: _answers,
              )));
    }).catchError((onError) {
      AlertDialog(
        content: Text("Koneksi eror.. coba lagi"),
        title: Text("Warning!"),
        actions: <Widget>[
          FlatButton(
            child: Text("Confirm"),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ],
      );
    });
  }

  Future<void> _nextSubmit() async {
    if (_answers[_currentIndex] == null) {
      _key.currentState.showSnackBar(SnackBar(
        content: Text("You must select an answer to continue."),
      ));
      return;
    }
    if (_currentIndex < (quizList.length - 1)) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _saveData();
    }
  }

  Future<bool> _onWillPop() async {
    return showDialog<bool>(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: Text(
                "Yakin keluar? Quiz yang telah dikerjakan tidak akan tersimpan"),
            title: Text("Warning!"),
            actions: <Widget>[
              FlatButton(
                child: Text("Yes"),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
              FlatButton(
                child: Text("No"),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
            ],
          );
        });
  }
}
