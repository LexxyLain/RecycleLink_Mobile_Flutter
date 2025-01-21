import 'package:flutter/material.dart';
import 'package:recyclelinkkkkkkkkkkk/collector_pricing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pickup_requests.dart';
import 'collector_transaction_history.dart';
import 'collectorcurrent_activity.dart'; 
import 'mapping_collector.dart';
import 'collector_pricing.dart';

class CollectorDashboard extends StatefulWidget {
  const CollectorDashboard({Key? key}) : super(key: key);

  @override
  _CollectorDashboardState createState() => _CollectorDashboardState();
}

class _CollectorDashboardState extends State<CollectorDashboard> {
  int? collectorId; // Allow null initially
  String collectorName = '';
  
  get userId => null;

  @override
  void initState() {
    super.initState();
    _loadCollectorData();
  }

  Future<void> _loadCollectorData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      collectorId = prefs.getInt('collector_id') ?? 0;
      collectorName = prefs.getString('fullname') ?? 'Collector';
    });
    print('Loaded collector ID: $collectorId, Collector Name: $collectorName');
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
                await prefs.remove('collector_id');
                await prefs.remove('fullname');
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
        title: const Text('Collector Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome to your dashboard!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 46, 127, 50),
              ),
            ),
            DashboardItem(
              icon: Icons.request_page,
              label: 'Pickup Requests',
              color: const Color.fromARGB(255, 47, 125, 50),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PickupRequests(collectorId: collectorId ?? 0),
                  ),
                );
              },
            ),
           
            DashboardItem(
              icon: Icons.local_activity,
              label: 'Current Activity',
              color: const Color.fromARGB(255, 47, 125, 50),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CollectorCurrentActivity(collectorId: collectorId ?? 0),
                  ),
                );
              },
            ),
            
            DashboardItem(
              icon: Icons.map,
              label: 'View Map',
              color: const Color.fromARGB(255, 46, 126, 49),
              onTap: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MappingCollector(userId: userId),
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
                          builder: (context) => const CollectorPricingPage(),
                        ),
                      );
                    },
                  ),
             DashboardItem(
              icon: Icons.history,
              label: 'Transaction History',
              color: const Color.fromARGB(255, 46, 126, 49),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CollectorTransactionHistory(collectorId: collectorId ?? 0),
                  ),
                );
              },
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
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
            SizedBox(width: 40),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
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
}
