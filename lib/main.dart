import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:restock_client/controllers/app_context.dart';
import 'package:restock_client/views/loading.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ChangeNotifierProvider(
    create: (context) => AppContext(),
    child: MaterialApp(
      title: 'Restonks',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoadingScreen(),
    ),
  ));
}

