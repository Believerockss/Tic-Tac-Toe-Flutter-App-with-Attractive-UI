import 'package:TicTacToe/screens/home_screen.dart';

final String findingOpp = "Finding Opponent Player....";
final String watchEarn = "Watch Ads and Earn";
const String LAGUAGE_CODE = 'languageCode';

final int plusPurchaseCoin = 10;
final int squarePurchaseCoin = 1000;
final int polygonPurchaseCoin = 1500;
final int hexaPurchaseCoin = 2500;
final int octaPurchaseCoin = 4000;
final int trianglePurchaseCoin = 6000;
final int diamondPurchaseCoin = 8500;

final String c100 = "100 Coins";
final String c500 = "500 Coins";
final String c1000 = "1000 Coins";
final String c2000 = "2000 Coins";
final String c5000 = "5000 Coins";
final String c50000 = "50000 Coins";

final String price2 = "2 USD";
final String price10 = "10 USD";
final String price50 = "50 USD";
final String price100 = "100 USD";
final String price250 = "250 USD";
final String price500 = "500 USD";

final Map userSkin = {
  "DORA Classic": {
    'userSkin': "cross_skin",
    'opponentSkin': "circle_skin",
    'price': 0
  },
  "DORA Plus": {
    'userSkin': "plus_skin",
    'opponentSkin': "circle_skin",
    'price': 100
  },
  "DORA Square": {
    'userSkin': "square_skin",
    'opponentSkin': "circle_skin",
    'price': 150
  },
  "DORA Polygon": {
    'userSkin': "polygon_skin",
    'opponentSkin': "cross_skin",
    'price': 150
  },
  "DORA Hexagon": {
    'userSkin': "hexagon_skin",
    'opponentSkin': "cross_skin",
    'price': 200
  },
  "DORA Octagon": {
    'userSkin': "octagon_skin",
    'opponentSkin': "circle_skin",
    'price': 15000
  },
  "DORA Triangle": {
    'userSkin': "triangle_skin",
    'opponentSkin': "circle_skin",
    'price': 150
  },
  "DORA Diamond": {
    'userSkin': "diamond_skin",
    'opponentSkin': "circle_skin",
    'price': 150
  },
  "DORA Offer": {
    'userSkin': "cross_skin",
    'opponentSkin': "octagon_skin",
    'price': 0
  },
};

List<String> rtlLanguages = ['ar'];

//These icons are svg file names without extension
List<Item> coinList = [
  Item(icon: "coin_1", name: c100, desc: price2),
  Item(icon: "coin_2", name: c500, desc: price10),
  Item(icon: "coin_3", name: c1000, desc: price50),
  Item(icon: "coinbag_1", name: c2000, desc: price100),
  Item(icon: "coinbag_2", name: c5000, desc: price250),
  Item(icon: "coinbag_2", name: c50000, desc: price500),
  Item(icon: "watchad_icon", name: watchEarn, desc: "")
];
