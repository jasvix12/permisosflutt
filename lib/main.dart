import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';  // Importamos Firebase
import 'package:firebase_messaging/firebase_messaging.dart'; // para FCM
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; //Para notificaciones locales
import 'src/pages/splash-screen.dart'; // Importamos el archivo splash_screen.dart

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


//Manejador de mensajes en segundo plano
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Notificacion en segundo plano: ${message.notification?.title}");


//Muestra una notificacion local cuando la app esta en segundo plano o cerrada
const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
  'your_channel_id', //ID del canal
  'your_channel_name', //Nombre del canal
  importance: Importance.max,
  priority: Priority.high,
  showWhen: false,
);

const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0, // ID de la notificación
    message.notification?.title, // Título de la notificación
    message.notification?.body, // Cuerpo de la notificación
    platformChannelSpecifics,
    payload: 'data', // Datos adicionales (opcional)
  );
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

// Configura el canal de notificaciones para Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'your_channel_id', // ID del canal
    'your_channel_name', // Nombre del canal
    importance: Importance.max,
  );

 // Crea el canal de notificaciones
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

 // Configura flutter_local_notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher'); // Icono de la app

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: null, // Configura iOS si es necesario
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Configura Firebase Messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Solicita permiso para recibir notificaciones (iOS)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  // Obtén el token FCM
  String? token = await messaging.getToken();
  print("FCM Token: $token");

  // Escucha mensajes en primer plano
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');

      // Muestra una notificación local
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'your_channel_id', // ID del canal
        'your_channel_name', // Nombre del canal
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      flutterLocalNotificationsPlugin.show(
        0, // ID de la notificación
        message.notification?.title, // Título de la notificación
        message.notification?.body, // Cuerpo de la notificación
        platformChannelSpecifics,
        payload: 'data', // Datos adicionales (opcional)
      );
    }
  });

  //Configura el manejador de mensajes en segundo plano 
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

