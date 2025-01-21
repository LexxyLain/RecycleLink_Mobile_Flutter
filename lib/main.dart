import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'user_dashboard.dart';
import 'register_page.dart';
import 'login_page.dart';
import 'user_registration.dart';
import 'collector_registration.dart';
import 'schedule_user.dart';
import 'transaction_history.dart';
import 'collector_dashboard.dart';
import 'pricing.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'RecycleLink',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.green,
          ),
          home: const LoginPage(), // Start with LoginPage
          routes: {
            '/login': (context) => const LoginPage(),
            '/register': (context) => RegisterPage(),
            '/userDashboard': (context) => const UserDashboard(),
            '/collectorDashboard': (context) => const CollectorDashboard(),
            '/userRegistration': (context) => const UserRegistration(),
            '/collectorRegistration': (context) => CollectorRegistration(),
            '/transactionHistory': (context) => const TransactionHistory(),
            '/pricing': (context) => const PricingPage(),
          },
          onGenerateRoute: (settings) {
            // Handle dynamic routes
            if (settings.name == '/chat') {
              final args = settings.arguments as Map<String, int>?; // Cast arguments to expected type
              
            } else if (settings.name == '/schedule') {
              final userId = settings.arguments as String?;
              return MaterialPageRoute(
                builder: (context) => Schedule(userId: userId ?? '0'),
              );
            }
            return null;
          },
        );
      },
    );
  }
}
