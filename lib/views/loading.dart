// the view when loading products and initialzing firebase/appcontext
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'dart:math';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'package:restock_client/views/home.dart';
import 'package:restock_client/controllers/app_context.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final List _loadingPhrases = [
    // 'Mining Bitcoin...',
    // 'Harvesting wheat...',
    // 'Cleaning the cartridge...',
    // 'Buffering video...'
    'Pulling parts...',
    'Connecting...'
  ];

  final List _loadingIndicators = [
    SpinKitWave,
    SpinKitCubeGrid,
    SpinKitSquareCircle,
    SpinKitChasingDots,
  ];

  String _phrase;
  var _indicator;
  bool err = false;

  pickRandom(arr) => arr[new Random().nextInt(arr.length)];

  @override
  void initState() {
    super.initState();

    _phrase = pickRandom(_loadingPhrases);
    _indicator = pickRandom(_loadingIndicators);

    WidgetsBinding.instance.addPostFrameCallback(_initConnection);
  }

  @override
  Widget build(BuildContext context) {
    AppContext appContext = Provider.of<AppContext>(context);

    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: appContext.primaryColor,
        child: Column(
          children: [
            Text(
              _phrase,
              // textAlign: TextAlign.center,
              style: TextStyle(fontSize: 36.0, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            if (!err)
              SpinKitWave(
                color: Colors.white,
                size: 50.0,
              ),
            if (err) Icon(Icons.error, color: Colors.red, size: 50),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
      ),
    );
  }

  void _initConnection(var _) async {
    AppContext appContext = Provider.of<AppContext>(context);

    try {
      await appContext.init();
      var products = await appContext.pullProducts();
      // await Future.delayed(const Duration(hours: 1));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(products),
        ),
      );
    } catch (error) {
      print("Error intiializing connection: $error");
      setState(() {
        err = true;
        _phrase = error.toString();
      });
    }
  }
}
