import 'dart:async';

import 'package:TicTacToe/Helper/color.dart';
import 'package:TicTacToe/Helper/constant.dart';
import 'package:TicTacToe/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class PrivacyPolicy extends StatefulWidget {
  final String? title;

  const PrivacyPolicy({super.key, this.title});

  @override
  State<StatefulWidget> createState() {
    return StatePrivacy();
  }
}

class StatePrivacy extends State<PrivacyPolicy> with TickerProviderStateMixin {
  late final WebViewController _controller;

  @override
  void initState() {
    //
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    ));
    //
    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
    //Advertisement.loadAd();
    super.initState();
  }

  @override
  void dispose() {
    //_onStateChanged.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          //  if (mounted) Advertisement.showAd();
          return Future.value(true);
        },
        child: SafeArea(
          child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                leading: Container(
                  margin: EdgeInsets.all(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () => Navigator.of(context).pop(),
                    child: Center(
                      child: Icon(
                        Icons.arrow_back,
                        size: 30,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  widget.title!,
                  style: TextStyle(color: primaryColor),
                ),
                backgroundColor: white,
              ),
              body: WebViewWidget(
                controller: _controller
                  ..loadRequest(Uri.parse("about:blank"))
                  ..enableZoom(true)
                  ..setJavaScriptMode(JavaScriptMode.unrestricted)
                  ..addJavaScriptChannel(
                    'Toaster',
                    onMessageReceived: (JavaScriptMessage message) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message.message)),
                      );
                    },
                  )
                  ..setNavigationDelegate(
                    NavigationDelegate(
                      onNavigationRequest: (NavigationRequest request) {
                        return NavigationDecision.navigate;
                      },
                    ),
                  )
                  ..loadHtmlString(widget.title == utils.getTranslated(context, "privacy")
                      ? privacyText
                      : (widget.title == utils.getTranslated(context, "termCond"))
                          ? termText
                          : (widget.title == utils.getTranslated(context, "aboutUs"))
                              ? aboutText
                              : contactText),
              )),
        ));
  }
}
