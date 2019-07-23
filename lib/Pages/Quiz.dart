import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pensieve_quiz/Models/Question.dart';
import 'package:pensieve_quiz/Models/QuizData.dart';
import 'package:pensieve_quiz/Utils/QuestionCard.dart';

class Quiz extends StatefulWidget {
  Quiz({@required this.user, @required this.documentID});

  final FirebaseUser user;
  final String documentID;

  @override
  _QuizState createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  QuizData _quizData;
  // int _questionIndex = 0;

  @override
  void initState() {
    super.initState();
    _quizData = QuizData(
      documentID: widget.documentID,
    );
    setBasicData(widget.documentID);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder<List<Question>>(
          future: _quizData.fetchQuizData(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Question>> snapshot) {
            if (snapshot.connectionState == ConnectionState.active ||
                snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("Error Occured. Please try again."),
                    SizedBox(
                      height: 10,
                    ),
                    FlatButton(
                      child: Text("Try Again"),
                      onPressed: () {
                        setState(() {});
                      },
                    ),
                  ],
                );
              }
              return QuestionCard(
                questionData: snapshot.data,
                user: widget.user,
                documentID: widget.documentID,
                // onCorrectSelection: () async {
                //   print("Correct Submission");
                //   await Firestore.instance
                //       .collection("monthlyQuizzes")
                //       .document(widget.documentID)
                //       .collection("participants")
                //       .document(widget.user.email)
                //       .updateData({
                //     "score": FieldValue.increment(
                //         snapshot.data[_questionIndex].reward),
                //     "finishTime": FieldValue.serverTimestamp(),
                //   });
                //   nextQuestion();
                // },
                // onIncorrectSelection: () {
                //   print("Incorrect Submission");
                //   nextQuestion();
                // },
                // onTimeOut: () {
                //   print("Time out");
                //   // nextQuestion();
                // },
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  void setBasicData(String docId) async {
    print("Comitted basic data");
    await Firestore.instance
        .collection("monthlyQuizzes")
        .document(docId)
        .collection("participants")
        .document(widget.user.email)
        .setData(
      {
        "displayName": widget.user.displayName,
        "emailID": widget.user.email,
        "uid": widget.user.uid,
        "photoUrl": widget.user.photoUrl,
      },
      merge: true,
    );
  }

  // nextQuestion() {
  //   if (_questionIndex < _quizData.questionsList.length - 1) {
  //     setState(() {
  //       _questionIndex++;
  //     });
  //   } else {
  //     Navigator.of(context).pushReplacement(
  //       PageRouteBuilder(
  //         pageBuilder: (BuildContext context, animation, secondsryAnimation) {
  //           return SlideTransition(
  //             child: Results(),
  //             position: Tween<Offset>(
  //               begin: Offset(1.0, 0),
  //               end: Offset.zero,
  //             ).animate(animation),
  //           );
  //         },
  //       ),
  //     );
  //   }
  // }
}