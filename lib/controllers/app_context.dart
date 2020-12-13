import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:restock_client/controllers/notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:restock_client/models/product.dart';

class AppContext extends ChangeNotifier {
  MessageContext _notificationController = MessageContext();
  FirebaseFirestore _firestore;

  AppContext();

  Future<bool> init() async {
    await Firebase.initializeApp();

    await _notificationController.initLocalNotifications();
    await _notificationController.initCloudMessaging();

    await initDatabase();
  }

  Future<bool> initDatabase() async {
    try {
      _firestore = FirebaseFirestore.instance;
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  Future<List> pullProducts() async {
    // pulls available products from firestore database
    final snapshot = await _firestore.collection('products').get();

    // convert workouts to workout class
    var products = snapshot.docs.map(
      (doc) => Product.fromJson(doc.data(), doc.id),
    );
    return products.toList();
  }
}
