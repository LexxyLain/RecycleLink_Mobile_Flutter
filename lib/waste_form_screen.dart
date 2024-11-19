import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class WasteFormScreen extends StatefulWidget {
  final DateTime selectedDate;

  const WasteFormScreen({super.key, required this.selectedDate});

  @override
  _WasteFormScreenState createState() => _WasteFormScreenState();
}

class _WasteFormScreenState extends State<WasteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _wasteType;
  String? _wasteSize;
  String? _address;
  String? _contactNum;
  final List<String> _sizes = ['Small (1-5kgs)', 'Medium (6-20kgs)', 'Large (21-45kgs)', 'XL (46kgs++)'];
  Uint8List? _imageData; 

  String? selectedSize;
  DateTime? selectedDate;
  TimeOfDay? selectedTime; 
  final TextEditingController applianceController = TextEditingController();

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _imageData = result.files.first.bytes;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  void confirmDetails() {
    if (selectedSize != null &&
        applianceController.text.isNotEmpty &&
        selectedDate != null &&
        selectedTime != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmation'),
          content: Text(
            '${'Size: $selectedSize\n'
            'Appliance: ${applianceController.text}\n'
            'Date of Pick Up: ${selectedDate!.toLocal()}'.split(' ')[0]}\nTime of Pick Up: ${selectedTime!.format(context)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all details and pick an image.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Waste Pickup Form'),
        backgroundColor: Colors.green[400],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pickup Date: ${widget.selectedDate.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),

                // Image preview for selected e-waste type
                _imageData != null
                    ? Image.memory(
                        _imageData!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 100,
                        width: 100,
                        color: Colors.grey[300],
                        child: const Center(child: Text('No Image Selected')),
                      ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _pickImage, // Call the image picker
                  child: const Text('Pick an Image from Gallery'),
                ),

                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Device/Appliance'),
                  onChanged: (value) {
                    _wasteType = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the type of e-waste';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Size of Device/Appliance'),
                  value: _wasteSize,
                  onChanged: (newValue) {
                    setState(() {
                      _wasteSize = newValue;
                    });
                  },
                  items: _sizes.map((size) {
                    return DropdownMenuItem(
                      value: size,
                      child: Text(size),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select the size';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Address'),
                  onChanged: (value) {
                    _address = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please input your complete address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Contact Number'),
                  onChanged: (value) {
                    _contactNum = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please input your contact number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                const Text(
                  'Select Pick Up Time:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => _selectTime(context),
                  child: Text(
                    selectedTime != null
                        ? 'Selected Time: ${selectedTime!.format(context)}'
                        : 'Choose Pick Up Time',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      confirmDetails();
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
