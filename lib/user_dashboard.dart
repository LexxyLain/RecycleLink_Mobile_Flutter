import 'package:flutter/material.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'pricing.dart';
import 'schedule_user.dart';
import 'transaction_history.dart';
import 'current_activity.dart'; 
import 'mapping.dart';
import 'pricing.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int userId = 0;
  String username = ''; 

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id') ?? 0;
      username = prefs.getString('full_name') ?? 'User';
    });
    if (userId == 0) {
      // If user is not logged in, redirect to login page
      Navigator.pushReplacementNamed(context, '/login');
    }
    print('User ID: $userId, Username: $username');
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout Confirmation'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: Text(
          'Hello, $username!',  // Displays the full name here
          style: const TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false, // Remove the back button
        actions: [
         
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),  // Logout icon color set to white
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to your dashboard!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'User ID: $userId', 
              style: TextStyle(
                fontSize: 16,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  DashboardItem(
                    icon: Icons.today,
                    label: 'Schedule Pickup',
                    color: Colors.green[800]!,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Schedule(userId: userId.toString())
                        ),
                      );
                    },
                  ),
                  DashboardItem(
                    icon: Icons.check_circle,
                    label: 'Current Activity',
                    color: Colors.green[800]!,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CurrentActivity(userId: userId),
                        ),
                      );
                    },
                  ),
                  DashboardItem(
                      icon: Icons.map,
                      label: 'View Map',
                      color: Colors.green[800]!,
                      onTap: () {
                        var collectorId;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MappingScreen(
                              latitude: 51.505,  // Replace with the user's actual latitude
                              longitude: -0.09,  // Replace with the user's actual longitude
                              title: 'User Map',
                              userId: userId,
                              collectorId: collectorId ?? 0,  // Pass collectorId (use default if null)
                            ),
                          ),
                        );
                      },
                    ),
                   DashboardItem(
                    icon: Icons.attach_money,
                    label: 'View Pricing',
                    color: Colors.green[800]!,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PricingPage(),
                        ),
                      );
                    },
                  ),
                  DashboardItem(
                    icon: Icons.history_rounded,
                    label: 'Transaction History',
                    color: Colors.green[800]!,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TransactionHistory()), 
                      );
                    },
                  ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }


class DashboardItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const DashboardItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 250, 249, 249).withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  toWidget() {}
}
