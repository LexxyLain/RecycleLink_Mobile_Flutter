import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50], 
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        title: const Text('Register'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.app_registration,
                color: Colors.green[300],
                size: 100,
              ),
              const SizedBox(height: 20),
              Text(
                'Select Account Type',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showRoleSelectionDialog(context);
                  },
                  icon: const Icon(Icons.account_circle, color: Colors.white),
                  label: const Text('Register Here'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[400], 
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoleSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Role',
            style: TextStyle(color: Colors.green[700]),
          ),
          content: const Text('Are you registering as a User or a Collector?'),
          actions: <Widget>[
            TextButton(
              child: Text('User', style: TextStyle(color: Colors.green[600])),
              onPressed: () {
                Navigator.of(context).pop(); 
                Navigator.pushNamed(context, '/userRegistration'); 
              },
            ),
            TextButton(
              child: Text('Collector', style: TextStyle(color: Colors.green[600])),
              onPressed: () {
                Navigator.of(context).pop(); 
                Navigator.pushNamed(context, '/collectorRegistration'); 
              },
            ),
          ],
        );
      },
    );
  }
}
