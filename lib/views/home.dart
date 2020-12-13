import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:restock_client/controllers/app_context.dart';
import 'package:restock_client/models/product.dart';

const CARDS = [
  '3060ti',
  '3070',
  '3080',
  '3090',
  'rx6800',
  'rx6800xt',
  'rx6900xt',
  'ryzen5600',
  'ryzen5800',
  'ryzen5900',
  'ryzen5950',
  'sonyps5c',
  'sonyps5de',
  'xboxss',
  'xboxsx'
];

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _homeScreenText = "Body";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(41, 60, 79, 1),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildTopVisual(),
        Expanded(child: _buildProducts()),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }

  Widget _buildTopVisual() {
    final pHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: pHeight * 0.4,
    );
  }

  Widget _buildProducts() {
    var appContext = Provider.of<AppContext>(context);
    return FutureBuilder(
      // Initialize FlutterFire:
      future: appContext.pullProducts(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(
            child: Icon(Icons.error, color: Colors.red),
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return _buildProductList(snapshot.data);
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Center(
          child: SpinKitRotatingCircle(color: Colors.white, size: 50.0),
        );
      },
    );
  }


  Widget _buildProductList(List products) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return Card(
          child: SwitchListTile(
            title: Text(
              '${products[index].name}',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            value: true,
            onChanged: (bool value) {
              setState(() {
                // _lights = value;
              });
            },
          ),
        );
      },
    );
  }
}
