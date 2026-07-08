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
  File? _selectedImage;
  File? _resultImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  // 选择照片
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _resultImage = null;
      });
    }
  }

  // 上传照片到后端做姿态侦测
  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 注意：这里的网址之后要改成你电脑的实际 IP
      var uri = Uri.parse("http://192.168.1.11:8000/detect-pose");
      var request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath('file', _selectedImage!.path),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        var bytes = await response.stream.toBytes();
        final tempFile = File('${_selectedImage!.path}_result.png');
        await tempFile.writeAsBytes(bytes);
        setState(() {
          _resultImage = tempFile;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('上传失败，请检查后端服务器')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发生错误：$e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 换装 App')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_selectedImage != null)
                Image.file(_selectedImage!, height: 250),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('选择照片'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _selectedImage == null ? null : _uploadImage,
                child: const Text('上传并侦测姿态'),
              ),
              const SizedBox(height: 16),
              if (_isLoading) const CircularProgressIndicator(),
              if (_resultImage != null) ...[
                const Text('处理结果：'),
                const SizedBox(height: 8),
                Image.file(_resultImage!, height: 250),
              ],
            ],
          ),
        ),
      ),
    );
  }
}