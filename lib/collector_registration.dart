import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class CollectorRegistration extends StatefulWidget {
  const CollectorRegistration({super.key});

  @override
  _CollectorRegistrationState createState() => _CollectorRegistrationState();
}

class _CollectorRegistrationState extends State<CollectorRegistration> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _reenterpasswordController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();

  Uint8List? _validIDData;
  Uint8List? _policeClearanceData;

  // Method to pick an image for valid ID or police clearance
  Future<void> _pickImage(bool isPoliceClearance) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          if (isPoliceClearance) {
            _policeClearanceData = result.files.first.bytes;
          } else {
            _validIDData = result.files.first.bytes;
          }
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  // Method to send registration data to PHP backend
  Future<void> _registerCollector() async {
    if (!_formKey.currentState!.validate() || _validIDData == null || _policeClearanceData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and upload the required documents.')),
      );
      return;
    }

    String url = 'http://kayemndjr11.helioho.st/api/collector.php'; // Update this URL if needed

    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Add fields to request
    request.fields['fullname'] = '${_firstNameController.text} ${_lastNameController.text}';
    request.fields['email'] = _emailController.text;
    request.fields['password'] = _passwordController.text; // Ensure you only send the hashed password
    request.fields['phone'] = _contactController.text;
    request.fields['address'] = _addressController.text;

    // Add files to request
    request.files.add(http.MultipartFile.fromBytes(
      'police_clearance',
      _policeClearanceData!,
      filename: 'police_clearance.jpg',
    ));

    request.files.add(http.MultipartFile.fromBytes(
      'valid_id',
      _validIDData!,
      filename: 'valid_id.jpg',
    ));

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseBody);

        print(jsonResponse);

        if (jsonResponse['success']) {
          _navigateToCollectorDashboard();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: ${jsonResponse['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error registering collector: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register. Please try again.')),
      );
    }
  }

  // Navigate to dashboard after successful registration
  void _navigateToCollectorDashboard() {
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collector Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // First Name Field
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                // Last Name Field
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                // Re-enter Password Field
                TextFormField(
                  controller: _reenterpasswordController,
                  decoration: InputDecoration(labelText: 'Re-enter Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty || value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                // Address Field
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                // Contact Number Field
                TextFormField(
                  controller: _contactController,
                  decoration: InputDecoration(labelText: 'Contact Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your contact number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Text('Valid ID:'),
                SizedBox(height: 10),
                _validIDData == null
                    ? Text('No image selected.')
                    : Image.memory(_validIDData!, height: 200, width: 200),
                ElevatedButton(
                  onPressed: () => _pickImage(false),
                  child: Text('Select Valid ID'),
                ),
                SizedBox(height: 20),
                Text('Police Clearance:'),
                SizedBox(height: 10),
                _policeClearanceData == null
                    ? Text('No image selected.')
                    : Image.memory(_policeClearanceData!, height: 200, width: 200),
                ElevatedButton(
                  onPressed: () => _pickImage(true),
                  child: Text('Select Police Clearance'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _registerCollector,
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
