import 'dart:math';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';

import '../Helper/color.dart';
import '../Helper/constant.dart';
import '../Helper/utils.dart';
import '../functions/dialoges.dart';
import '../functions/getCoin.dart';
import '../widgets/alertDialoge.dart';
import 'splash.dart';

class SinglePlayerScreenActivity extends StatefulWidget {
  String? playerSkin, doraSkin;
  final int? levelType;

  SinglePlayerScreenActivity(this.playerSkin, this.doraSkin, this.levelType);

  @override
  _SinglePlayerScreenActivityState createState() =>
      _SinglePlayerScreenActivityState();
}

class _SinglePlayerScreenActivityState extends State<SinglePlayerScreenActivity>
    with ChangeNotifier {
  CountDownController _countDownPlayer = CountDownController();
  String? player;

  String gameStatus = "";

  String? winner = "0";
  int calledCount = 0;
  int tieCalled = 0;
  Utils u = Utils();
  Map buttons = Map();
  late Random rnd;
  String? currentMove, _profilePic = "", _username = "";

  @override
  void initState() {
    super.initState();
    buttons = u.gameButtons;

    rnd = Random();

    int rndVal = rnd.nextInt(2);

    player = rndVal == 0 ? "X" : "O";
    gameStatus = "started";
    getFieldValue("profilePic", (e) => _profilePic = e, (e) => _profilePic = e);
    getFieldValue("username", (e) => _username = e, (e) => _username = e);

    // For Compatibility with older versions, as we have changed to use svg instead of png.
    if (widget.doraSkin!.endsWith('.png')) {
      widget.doraSkin =
          widget.doraSkin!.split('.png').first.split('images/').last;
    }
    if (widget.playerSkin!.endsWith('.png')) {
      widget.playerSkin =
          widget.playerSkin!.split('.png').first.split('images/').last;
    }
    print("RM :: Dora Skin :: ${widget.doraSkin}");
    print("RM :: Player Skin :: ${widget.playerSkin}");
    Future.delayed(Duration.zero, playGame);
  }

  getFieldValue(
    String fieldName,
    void Function(dynamic count) callback,
    void Function(dynamic count) update,
  ) async {
    var init;
    try {
      var ins = GetUserInfo();
      init = await (await ins.getFieldValue(fieldName));
      if (mounted) {
        setState(() {
          callback(init);
        });
      }
      await ins.detectChange(fieldName, (val) {
        if (mounted) {
          setState(() {
            update(val);
          });
        }
      });
    } catch (err) {}
  }

  @override
  void didChangeDependencies() {
    currentMove = player == "X"
        ? utils.getTranslated(context, "doraTurn")
        : utils.getTranslated(context, "yourTurn");
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _countDownPlayer.reset();
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

            Future.delayed(const Duration(seconds: 1)).then((value) {
              if (winner == "0" && gameStatus == "tie") {
                Dialoge()
                  ..tie(context, "Singleplayer", "", "", widget.playerSkin,
                      widget.doraSkin, widget.levelType);
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
        winner == "1" ? _username : utils.getTranslated(context, "dora"),
        winner == "1" ? _profilePic : "",
        "",
        "",
        "",
      );
    }
  }

  playGame([i]) async {
    var seconds = 1;
    rnd = Random();
    seconds = rnd.nextInt(countdowntime - 4) + 1;

    if (gameStatus == "started") {
      currentMove = player == "X"
          ? utils.getTranslated(context, "doraTurn")
          : utils.getTranslated(context, "yourTurn");

      setState(() {});
      if (gameStatus == "started") {
        check();
      }
      if (player == "X") {
        await Future.delayed(Duration(milliseconds: seconds * 500))
            .then((_) async {
          var currentBoardState = [];

          int j = 0;

          for (var i = 0; i <= 8; i++) {
            if (buttons[i]["state"] == "") {
              currentBoardState.add(i);
              j++;
            } else if (buttons[i]["player"] != "2") {
              currentBoardState.add("X");
            } else if (buttons[i]["player"] != "1") {
              currentBoardState.add("O");
            }
          }
          var r;
          if (widget.levelType == 2) {
            if (j <= 8) {
              var bestSpot = minimax(currentBoardState, "O");
              r = bestSpot["index"];
            } else {
              rnd = Random();
              r = rnd.nextInt(9);
            }
          } else if (widget.levelType == 1) {
            if (j <= 6) {
              var bestSpot = minimax(currentBoardState, "O");
              r = bestSpot["index"];
            } else {
              rnd = Random();
              r = rnd.nextInt(9);
            }
          } else {
            rnd = Random();
            r = rnd.nextInt(9);
          }

          if (buttons[r]["state"] == "") {
            music.play(dice);

            buttons[r]["state"] = "true";
            buttons[r]["player"] = "2";

            _countDownPlayer.restart();
            currentMove = utils.getTranslated(context, "yourTurn");

            player = "O";
            if (gameStatus == "started") {
              check();
            }
            setState(() {});
          } else {
            if (gameStatus == "started") {
              if (mounted) {
                playGame();
              }
            }
          }
        });
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

          currentMove = utils.getTranslated(context, "doraTurn");

          setState(() {});
          playGame();
          if (gameStatus == "started") {
            check();
          }
        }
        if (gameStatus == "started") {
          check();
        }
      }
    }
  }

  bool checkWinning(board, player) {
    if ((board[0] == player && board[1] == player && board[2] == player) ||
        (board[3] == player && board[4] == player && board[5] == player) ||
        (board[6] == player && board[7] == player && board[8] == player) ||
        (board[0] == player && board[3] == player && board[6] == player) ||
        (board[1] == player && board[4] == player && board[7] == player) ||
        (board[2] == player && board[5] == player && board[8] == player) ||
        (board[0] == player && board[4] == player && board[8] == player) ||
        (board[2] == player && board[4] == player && board[6] == player)) {
      return true;
    } else {
      return false;
    }
  }

  var dora = "X", human = "O";

  dynamic minimax(newBoard, player) {
    var availableSpots = [];

    for (var i = 0; i <= 8; i++) {
      if (newBoard[i] != "X" && newBoard[i] != "O") {
        availableSpots.add(i);
      }
    }
    if (checkWinning(newBoard, dora)) {
      return {"score": 10};
    } else if (checkWinning(newBoard, human)) {
      return {"score": -10};
    } else if (availableSpots.isEmpty) {
      return {"score": 0};
    }

    var moves = [];

    for (var i = 0; i < availableSpots.length; i++) {
      var move = {};
      move["index"] = newBoard[availableSpots[i]];

      newBoard[availableSpots[i]] = player;
      if (player == dora) {
        var result = minimax(newBoard, human);

        move["score"] = result["score"];
      } else {
        var result = minimax(newBoard, dora);

        move["score"] = result["score"];
      }
      newBoard[availableSpots[i]] = move["index"];
      moves.add(move);
    }

    var bestmove;

    if (player == dora) {
      var bestscore = -10000;
      for (var i = 0; i < moves.length; i++) {
        if (moves[i]["score"] > bestscore) {
          bestscore = moves[i]["score"];
          bestmove = i;
        }
      }
    } else {
      var bestscore = 10000;
      for (var i = 0; i < moves.length; i++) {
        if (moves[i]["score"] < bestscore) {
          bestscore = moves[i]["score"];
          bestmove = i;
        }
      }
    }
    return moves[bestmove];
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          showQuitGameDialog();
          return Future.value(false);
        },
        child: Scaffold(
          body: Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: utils.gradBack(),
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
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
                                _countDownPlayer.pause();

                                currentMove !=
                                        utils.getTranslated(context, "doraTurn")
                                    ? Dialoge.winner(
                                        context,
                                        utils.getTranslated(context, "dora"),
                                        "",
                                        "",
                                        "",
                                        "")
                                    : Dialoge.winner(
                                        context, "$_username", "", "", "", "");
                                setState(() {});
                              },
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                  start: 8.0, end: 8.0),
                              child: Text("$currentMove"),
                            )
                          ],
                        ),
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
                                mainAxisSpacing: 10,
                              ),
                              itemCount: 9,
                              itemBuilder: (context, i) {
                                return GestureDetector(
                                  onTap: () async {
                                    await Future.delayed(
                                        Duration(milliseconds: 500));
                                    if (gameStatus == "started" &&
                                        currentMove ==
                                            utils.getTranslated(
                                                context, "yourTurn")) {
                                      playGame(i);
                                    }
                                  },
                                  child: Stack(fit: StackFit.expand, children: [
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
                                    buttons[i]['state'] == ""
                                        ? const SizedBox()
                                        : Padding(
                                            padding: EdgeInsets.all(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05),
                                            child: getSvgImage(
                                              imageName: utils.returnImage(
                                                i,
                                                buttons,
                                                widget.playerSkin,
                                                widget.doraSkin,
                                              ),
                                              height: double.maxFinite,
                                              width: double.maxFinite,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                  ]),
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
                            (_profilePic ?? "") != ""
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(_profilePic!),
                                    radius: 25,
                                  )
                                : CircleAvatar(
                                    child: getSvgImage(
                                        imageName: "signin_Dora",
                                        width: 154,
                                        height: 172),
                                    radius: 25,
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
                                      // HERE
                                      getSvgImage(
                                        imageName: widget.playerSkin!,
                                        height: 12,
                                        imageColor: secondarySelectedColor,
                                      ),
                                      // Image.asset(
                                      //   widget.playerSkin!,
                                      //   height: 12,
                                      //   color: secondarySelectedColor,
                                      // )
                                    ],
                                  ),
                                  Text(
                                    "${utils.limitChar(_username!, 7)}",
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
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    getSvgImage(
                                      imageName: widget.doraSkin!,
                                      height: 12,
                                    ),
                                    // Image.asset(
                                    //   widget.doraSkin!,
                                    //   height: 12,
                                    // ),
                                    Text(
                                      " : ${utils.getTranslated(context, "sign")}",
                                    ),
                                  ],
                                ),
                                Text(
                                  utils.getTranslated(context, "dora"),
                                  style: TextStyle(color: white),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: getSvgImage(
                                    imageName: 'signin_Dora',
                                    width: 154,
                                    height: 137),
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
}
