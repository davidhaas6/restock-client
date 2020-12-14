import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:restock_client/controllers/notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:restock_client/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppContext extends ChangeNotifier {
  MessageContext _notificationController = MessageContext();
  FirebaseFirestore _firestore;
  SharedPreferences preferences;

  AppContext();

  Future<bool> init() async {
    preferences = await SharedPreferences.getInstance();

    await Firebase.initializeApp();

    await _notificationController.initLocalNotifications();
    await _notificationController.initCloudMessaging();

    await initDatabase();
  }

  // Initializes connection with Firebase database
  Future<bool> initDatabase() async {
    try {
      _firestore = FirebaseFirestore.instance;
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  // pulls available products from firestore database
  Future<List> pullProducts() async {
    final productCollection = await _firestore.collection('products').get();

    // convert workouts to workout class
    var products = productCollection.docs.map(
      (doc) => Product.fromJson(doc.data(), doc.id),
    ).toList();

    // register new products with notification system
    for (var product in products){
      if (!preferences.containsKey(product.id)) {
        preferences.setBool(product.id, false);
      }
    }


    return products;
  }

  followProduct(Product product) {
    preferences.setBool(product.id, true);
  }

  unfollowProduct(Product product) {
    preferences.setBool(product.id, false);
  }

  isFollowing(Product product) {
    return preferences.getBool(product.id);
  }
}
