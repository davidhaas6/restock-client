import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:restock_client/controllers/app_context.dart';
import 'package:restock_client/controllers/notifications.dart';
import 'package:provider/provider.dart';

import 'package:restock_client/views/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ChangeNotifierProvider(
    create: (context) => AppContext(),
    child: MaterialApp(
      title: 'Notifier',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RestockClient(),
    ),
  ));
}

class RestockClient extends StatefulWidget {
  @override
  _RestockClientState createState() => _RestockClientState();
}

class _RestockClientState extends State<RestockClient> {
  Future<bool> initFirebase(AppContext providerContext) async {
    bool enabledNotifications = await providerContext.initCloudFunctions();
    FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
    return enabledNotifications;
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    var appContext = Provider.of<AppContext>(context);
    return FutureBuilder(
      // Initialize FlutterFire:
      future: initFirebase(appContext),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          print(snapshot.error);
          return _buildInitError();
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return HomePage();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return _buildLoading();
      },
    );
  }

  Widget _buildLoading() {
    return Column(
      children: [
        Text(
          "Connecting to Server...",
          style: TextStyle(color: Colors.white, fontSize: 24),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 10,
        ),
        SpinKitRotatingCircle(
          color: Colors.white,
          size: 50.0,
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }

  Widget _buildInitError() {
    return Center(
      child: Text("Error initializing app"),
    );
  }
}
