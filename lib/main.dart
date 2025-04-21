import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prodigenious/services/firestore_task_services.dart';
import 'package:prodigenious/services/notificaiton_service.dart';
import 'package:prodigenious/services/task_estimator_service.dart';
import 'package:prodigenious/view/forgot_password_screen.dart';
import 'package:prodigenious/view/home_screen.dart';
import 'package:prodigenious/view/notification_screen.dart';
import 'package:prodigenious/view/productivity_screen.dart';
import 'package:prodigenious/view/profile_screen.dart';
import 'package:prodigenious/view/scheduled_tasks_screen.dart';
import 'package:prodigenious/viewmodel/auth_view_model.dart';
import 'package:prodigenious/viewmodel/productivity_view_model.dart';

import 'package:provider/provider.dart';
import 'view/splash_screen.dart';
import 'view/signup_screen.dart';
import 'view/login_screen.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    final now = DateTime.now();
    final firestore = FirebaseFirestore.instance;

    final snapshot = await firestore
        .collection('notifications')
        .where('isDelivered', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      final scheduled = (doc['scheduledDate'] as Timestamp).toDate();
      if (scheduled.isBefore(now)) {
        await doc.reference.update({'isDelivered': true});
      }
    }

    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Karachi'));
  await requestExactAlarmPermission();
  await TaskEstimatorService.init();
  await NotificationService.initNotification();
  await NotificationService.requestNotificationPermission();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await Workmanager().registerPeriodicTask(
    "checkNotificationDelivery",
    "checkNotificationDeliveryTask",
    frequency: const Duration(minutes: 15),
    initialDelay: const Duration(minutes: 1),
  );

  runApp(
    ScreenUtilInit(
      designSize: Size(440, 956),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ChangeNotifierProvider(
          create: (_) => ProductivityViewModel(),
          child: MyApp(),
        );
      },
    ),
  );
  checkAndMoveTasksToHistory();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/signup': (context) => SignupScreen(),
          '/login': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
          '/forgot_password': (context) => ForgotPasswordScreen(),
          '/notifications': (context) => NotificationsScreen(),
          '/profile': (context) => EditProfileScreen(),
          '/scheduled_task_screen': (context) => ScheduledTasksScreen(),
          '/productivity_screen': (context) => ProductivityScreen(),
        },
      ),
    );
  }
}
