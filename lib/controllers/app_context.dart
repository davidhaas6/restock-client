import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:restock_client/controllers/notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:restock_client/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppContext extends ChangeNotifier {
  MessageContext _notifications = MessageContext();
  FirebaseFirestore _firestore;
  SharedPreferences preferences;

  final Color primaryColor = Color.fromRGBO(41, 60, 79, 1);

  AppContext();

  Future<bool> init() async {
    preferences = await SharedPreferences.getInstance();

    await Firebase.initializeApp();

    await _notifications.initLocalNotifications();
    await _notifications.initCloudMessaging();

    await initDatabase();

    return true; //TODO
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
    var products = productCollection.docs
        .map(
          (doc) => Product.fromJson(doc.data(), doc.id),
        )
        .toList();

    // register new products with notification system
    for (var product in products) {
      if (!preferences.containsKey(product.id)) {
        await unfollowProduct(product);
      }
    }

    return products;
  }

  followProduct(Product product) async {
    preferences.setBool(product.id, true);
    await _notifications.messaging.subscribeToTopic(product.id);
    print("followed product ${product.id}");
  }

  unfollowProduct(Product product) async {
    preferences.setBool(product.id, false);
    await _notifications.messaging.unsubscribeFromTopic(product.id);
    print("unfollowed product ${product.id}");
  }

  isFollowing(Product product) {
    return preferences.getBool(product.id);
  }
}
