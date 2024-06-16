import 'dart:math';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';

import '../Helper/color.dart';
import '../Helper/constant.dart';
import '../Helper/utils.dart';
import '../functions/dialoges.dart';
import '../widgets/alertDialoge.dart';
import 'splash.dart';

class PassNPLay extends StatefulWidget {
  final String? player1, player2;
  String? player1Skin, player2Skin;

  PassNPLay(this.player1, this.player2, this.player1Skin, this.player2Skin);

  @override
  _PassNPLayState createState() => _PassNPLayState();
}

class _PassNPLayState extends State<PassNPLay> {
  CountDownController _countDownPlayer = CountDownController();
  String gameStatus = "";

  Utils u = Utils();
  Map buttons = Map();
  String? currentMove;
  late Random randomValue;
  String? player;
  String? winner = "0";
  int calledCount = 0;
  int tieCalled = 0;

  @override
  void initState() {
    super.initState();
    buttons = u.gameButtons;
    randomValue = Random();
    int randomNumber = randomValue.nextInt(2);

    player = randomNumber == 0 ? "X" : "O";
    gameStatus = "started";

    // For Compatibility with older versions, as we have changed to use svg instead of png.
    if (widget.player1Skin!.endsWith('.png')) {
      widget.player1Skin =
          widget.player1Skin!.split('.png').first.split('images/').last;
    }
    if (widget.player2Skin!.endsWith('.png')) {
      widget.player2Skin =
          widget.player2Skin!.split('.png').first.split('images/').last;
    }

    playGame();
  }

  void check() {
    for (var i = 0; i < buttons.length; i++) {
      for (var j = 0; j < utils.winningCondition.length; j++) {
        if (buttons[utils.winningCondition[j][0]]["player"] ==
                buttons[utils.winningCondition[j][1]]["player"] &&
            buttons[utils.winningCondition[j][1]]["player"] ==
                buttons[utils.winningCondition[j][2]]["player"] &&
            buttons[utils.winningCondition[j][1]]["player"] != "0") {
          winner = buttons[utils.winningCondition[j][1]]["player"];

          gameStatus = "over";

          calledCount += 1;
          setState(() {});
        } else {
          int _count = 0;
          for (var k = 0; k < buttons.length; k++) {
            if (buttons[k]["state"] != "" && winner == "0") {
              _count++;
            }
            if (_count == 9) {
              gameStatus = "tie";

              tieCalled += 1;
            }
          }

          if (_count == 9 && tieCalled == 1 && winner == "0") {
            if (mounted) {
              setState(() {});
            }

            music.play(tiegame);

            Future.delayed(Duration(seconds: 1)).then((value) {
              if (winner == "0" && gameStatus == "tie") {
                Dialoge()
                  ..tie(
                      context,
                      "passnplay",
                      widget.player1.toString(),
                      widget.player2.toString(),
                      widget.player1Skin,
                      widget.player2Skin);
              }
              _countDownPlayer.pause();
              setState(() {});
            });
          }
        }
      }
    }

    if (gameStatus == "over" && mounted && winner != "0") {
      winner == "1" ? music.play(wingame) : music.play(losegame);

      _countDownPlayer.pause();
      setState(() {});

      Dialoge.winner(
        context,
        winner == "1" ? widget.player2.toString() : widget.player1.toString(),
        "",
        "",
        "",
        "",
      );
    }
  }

  playGame([i]) async {
    if (gameStatus == "started") {
      currentMove = player == "X"
          ? widget.player1.toString() + " Turn"
          : widget.player2.toString() + " Turn";

      setState(() {});

      if (player == "X" && i != null) {
        if (buttons[i]["state"] == "") {
          music.play(dice);

          buttons[i]["state"] = "true";

          buttons[i]["player"] = "2";
          player = "O";
          _countDownPlayer.restart();

          currentMove = widget.player1.toString() + " Turn";

          setState(() {});

          playGame();
        }
        if (gameStatus == "started") {
          check();
        }
      }

      if (player == "O" && i != null) {
        if (buttons[i]["state"] == "") {
          music.play(dice);

          buttons[i]["state"] = "true";

          buttons[i]["player"] = "1";
          player = "X";
          _countDownPlayer.restart();

          currentMove = widget.player1.toString() + " Turn";

          setState(() {});

          playGame();
        }
        if (gameStatus == "started") {
          check();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          music.play(click);

          showDialog(
              context: context,
              builder: (context) {
                var color = secondaryColor;

                return Alert(
                  title: Text(
                    utils.getTranslated(context, "aleart"),
                    style: TextStyle(color: white),
                  ),
                  isMultipleAction: true,
                  defaultActionButtonName: utils.getTranslated(context, "ok"),
                  onTapActionButton: () {},
                  content: Text(
                    utils.getTranslated(context, "areYouSure"),
                    style: TextStyle(color: white),
                  ),
                  multipleAction: [
                    TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(color)),
                        onPressed: () async {
                          music.play(click);

                          Navigator.popUntil(
                              context, ModalRoute.withName("/home"));
                        },
                        child: Text(utils.getTranslated(context, "ok"),
                            style: TextStyle(color: white))),
                    TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(color)),
                        onPressed: () async {
                          music.play(click);

                          Navigator.pop(context);
                        },
                        child: Text(utils.getTranslated(context, "cancle"),
                            style: TextStyle(color: white)))
                  ],
                );
              });

          return await Future.value(false);
        },
        child: Scaffold(
          body: Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: utils.gradBack(),
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            CircularCountDownTimer(
                              height: 25,
                              duration: countdowntime,
                              ringColor: back,
                              fillColor: secondarySelectedColor,
                              width: 25,
                              strokeWidth: 3,
                              controller: _countDownPlayer,
                              textFormat: CountdownTextFormat.S,
                              textStyle: TextStyle(color: white, fontSize: 10),
                              // autoStart: player == "X" ? true : false,
                              isReverse: true,
                              initialDuration: 0,
                              onComplete: () async {
                                music.play(losegame);
                                Dialoge.winner(
                                    context,
                                    currentMove ==
                                            widget.player1.toString() + " Turn"
                                        ? "${widget.player2.toString()}"
                                        : "${widget.player1.toString()}",
                                    "",
                                    "",
                                    "",
                                    "");
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(start: 8.0),
                              child: Text("$currentMove"),
                            )
                          ],
                        ),
                        Spacer(),
                        IconButton(
                            padding: EdgeInsets.only(),
                            onPressed: () {
                              showQuitGameDialog();
                            },
                            icon: Icon(
                              Icons.logout,
                              color: back,
                            )),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Center(
                        child: Stack(
                          children: [
                            GridView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10),
                              itemCount: 9,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    await Future.delayed(
                                        Duration(milliseconds: 500));
                                    if (gameStatus == "started") {
                                      playGame(index);
                                    }
                                  },
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          margin: EdgeInsets.only(
                                            left: 2,
                                            right: 2,
                                            top: 30,
                                          ),
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white54,
                                                offset: Offset(0, 4),
                                                spreadRadius: 1.5,
                                                blurRadius: 7,
                                              ),
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(40),
                                          ),
                                        ),
                                      ),
                                      getSvgImage(
                                          imageName: 'grid_box',
                                          fit: BoxFit.fill),
                                      buttons[index]['state'] == ""
                                          ? Container()
                                          : Padding(
                                              padding: EdgeInsets.all(
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.05),
                                              child: getSvgImage(
                                                imageName: u.returnImage(
                                                    index,
                                                    buttons,
                                                    widget.player2Skin,
                                                    widget.player1Skin),
                                                height: double.maxFinite,
                                                width: double.maxFinite,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20, bottom: 20),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              child: getSvgImage(
                                  imageName: "signin_Dora",
                                  width: 154,
                                  height: 172),
                              radius: 25,
                              backgroundColor: Colors.transparent,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "${utils.getTranslated(context, "sign")} : ",
                                      ),
                                      getSvgImage(
                                        imageName: widget.player1Skin!,
                                        height: 12,
                                        imageColor: secondarySelectedColor,
                                      )
                                    ],
                                  ),
                                  Text(
                                    "${widget.player1.toString()}",
                                    style: TextStyle(color: white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: getSvgImage(
                              imageName: "vs_small", width: 22, height: 21),
                        ),
                        Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    getSvgImage(
                                      imageName: widget.player2Skin!,
                                      height: 12,
                                    ),
                                    Text(
                                      " : ${utils.getTranslated(context, "sign")}",
                                    ),
                                  ],
                                ),
                                Text(
                                  "${widget.player2.toString()}",
                                  style: TextStyle(color: white),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: getSvgImage(
                                    imageName: "signin_Dora",
                                    width: 154,
                                    height: 172),
                                radius: 25,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showQuitGameDialog() {
    music.play(click);
    showDialog(
        context: context,
        builder: (context) {
          var color = secondaryColor;

          return Alert(
            title: Text(
              utils.getTranslated(context, "aleart"),
              style: TextStyle(color: white),
            ),
            isMultipleAction: true,
            defaultActionButtonName: utils.getTranslated(context, "ok"),
            onTapActionButton: () {},
            content: Text(
              utils.getTranslated(context, "areYouSure"),
              style: TextStyle(color: white),
            ),
            multipleAction: [
              TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(color)),
                  onPressed: () async {
                    music.play(click);

                    Navigator.popUntil(context, ModalRoute.withName("/home"));
                  },
                  child: Text(utils.getTranslated(context, "ok"),
                      style: TextStyle(color: white))),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(color)),
                  onPressed: () async {
                    music.play(click);

                    Navigator.pop(context);
                  },
                  child: Text(utils.getTranslated(context, "cancle"),
                      style: TextStyle(color: white)))
            ],
          );
        });
  }
}
