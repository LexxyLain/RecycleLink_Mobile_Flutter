import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login(String role) async {
    setState(() {
      _isLoading = true;
    });

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter both email and password');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://kayemndjr11.helioho.st/api/login.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        if (role == 'collector') {
          if (responseData.containsKey('collector_id') &&
              responseData['status'] == 'Approved') {
            await prefs.setInt('collector_id', responseData['collector_id']);
            await prefs.setString('fullname', responseData['fullname'] ?? 'Collector'); // Collector uses 'fullname'

            Navigator.pushNamed(
              context,
              '/collectorDashboard',
              arguments: {
                'collector_id': responseData['collector_id'],
                'fullname': responseData['fullname'] ?? 'Collector',
              },
            );
          } else {
            _showMessage('Your account is awaiting approval');
          }
        } else if (role == 'user' && responseData.containsKey('user_id')) {
          await prefs.setInt('user_id', responseData['user_id']);
          await prefs.setString('fullname', responseData['full_name'] ?? 'User'); 

          Navigator.pushNamed(
            context,
            '/userDashboard',
            arguments: {
              'user_id': responseData['user_id'],
              'fullname': responseData['full_name'] ?? 'User', 
            },
          );
        } else {
          _showMessage('Login failed: Invalid role or ID');
        }

      } else {
        _showMessage(responseData['message'] ?? 'Login failed');
      }
    } catch (error) {
      _showMessage('Error occurred: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.recycling_rounded,
                color: Colors.green[900],
                size: 100,
              ),
              const SizedBox(height: 20),
              Text(
                'RecycleLink',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email, color: Colors.green[900]),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green[200]!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green[400]!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: Colors.green[900]),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green[200]!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green[400]!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Column for stacking buttons vertically
              Column(
                children: [
                  SizedBox(
                    width: 250, // Fixed width for both buttons
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => _login('user'),
                      icon: const Icon(Icons.person, color: Colors.white),
                      label: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Login as User',
                              style: TextStyle(color: Colors.white),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Space between buttons
                  SizedBox(
                    width: 250, // Fixed width for both buttons
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => _login('collector'),
                      icon: const Icon(Icons.local_shipping, color: Color.fromARGB(255, 241, 237, 237)),
                      label: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Login as Collector',
                              style: TextStyle(color: Colors.white),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text('Don\'t have an account? Register here.'),
                style: TextButton.styleFrom(foregroundColor: Colors.green[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
