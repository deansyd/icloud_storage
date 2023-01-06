import 'dart:async';
import 'package:flutter/material.dart';
import 'package:icloud_storage/icloud_storage.dart';
import 'utils.dart';

class Upload extends StatefulWidget {
  final String containerId;

  const Upload({super.key, required this.containerId});

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  final _containerIdController = TextEditingController();
  final _filePathController = TextEditingController();
  final _destPathController = TextEditingController();
  StreamSubscription<double>? _progressListner;
  String? _error;
  String? _progress;

  Future<void> _handleUpload() async {
    try {
      setState(() {
        _progress = 'Upload Started';
        _error = null;
      });

      await ICloudStorage.upload(
        containerId: _containerIdController.text,
        filePath: _filePathController.text,
        destinationRelativePath:
            _destPathController.text.isEmpty ? null : _destPathController.text,
        onProgress: (stream) {
          _progressListner = stream.listen(
            (progress) => setState(() {
              _progress = 'Upload Progress: $progress';
            }),
            onDone: () => setState(() {
              _progress = 'Upload Completed';
            }),
            onError: (err) => setState(() {
              _progress = null;
              _error = getErrorMessage(err);
            }),
            cancelOnError: true,
          );
        },
      );
    } catch (ex) {
      setState(() {
        _progress = null;
        _error = getErrorMessage(ex);
      });
    }
  }

  @override
  void initState() {
    _containerIdController.text = widget.containerId;
    super.initState();
  }

  @override
  void dispose() {
    _progressListner?.cancel();
    _containerIdController.dispose();
    _filePathController.dispose();
    _destPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('upload example'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _containerIdController,
                decoration: const InputDecoration(
                  labelText: 'containerId',
                ),
              ),
              TextField(
                controller: _filePathController,
                decoration: const InputDecoration(
                  labelText: 'filePath',
                ),
              ),
              TextField(
                controller: _destPathController,
                decoration: const InputDecoration(
                  labelText: 'destinationRelativePath (optional)',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handleUpload,
                child: const Text('UPLOAD'),
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              if (_progress != null)
                Text(
                  _progress!,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
