import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:restock_client/controllers/notifications.dart';
import 'package:flutter/foundation.dart';



class AppContext extends ChangeNotifier {
  MessageContext _notificationController = MessageContext();
  FirebaseFirestore firestore;

  AppContext();

  Future<bool> initCloudFunctions() async {
        await Firebase.initializeApp();

    await _notificationController.initLocalNotifications();
    await _notificationController.initMessaging();
  }

  Future<bool> initDatabase() async {
    try {
      firestore = FirebaseFirestore.instance;
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }
}
