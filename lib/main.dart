import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Clothing App',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _modelImage;   // Photo of the model/person
  File? _garmentImage; // Photo of the garment
  File? _resultImage;  // Try-on result (populated once the API call succeeds)
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickModelImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _modelImage = File(image.path);
      });
    }
  }

  Future<void> _pickGarmentImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _garmentImage = File(image.path);
      });
    }
  }

  // Calls the backend, which in turn calls the Replicate API
  Future<void> _startTryOn() async {
  if (_modelImage == null || _garmentImage == null) return;

  setState(() {
    _isLoading = true;
  });

  try {
    var uri = Uri.parse("http://192.168.100.14:8000/try-on");
    var request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('model_file', _modelImage!.path),
    );
    request.files.add(
      await http.MultipartFile.fromPath('garment_file', _garmentImage!.path),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      var bytes = await response.stream.toBytes();
      final tempFile = File('${_modelImage!.path}_tryon_result.png');
      await tempFile.writeAsBytes(bytes);
      setState(() {
        _resultImage = tempFile;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Try-on failed, please check the backend server')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $e')),
    );
  }

  setState(() {
    _isLoading = false;
  });
}

  Widget _buildImagePicker({
    required String title,
    required File? image,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 160,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: image == null
                ? const Center(child: Icon(Icons.add_a_photo, size: 40))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(image, fit: BoxFit.cover),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Try-On App')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImagePicker(
                    title: 'Model photo',
                    image: _modelImage,
                    onTap: _pickModelImage,
                  ),
                  _buildImagePicker(
                    title: 'Garment photo',
                    image: _garmentImage,
                    onTap: _pickGarmentImage,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: (_modelImage != null && _garmentImage != null)
                    ? _startTryOn
                    : null,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Start Try-On'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_isLoading) const CircularProgressIndicator(),
              if (_resultImage != null) ...[
                const Text('Try-On Result:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Image.file(_resultImage!, height: 300),
              ],
            ],
          ),
        ),
      ),
    );
  }
}