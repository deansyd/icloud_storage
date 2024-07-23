import 'dart:async';
import 'package:flutter/material.dart';
import 'package:icloud_storage/icloud_storage.dart';
import 'utils.dart';

class Download extends StatefulWidget {
  final String containerId;

  const Download({super.key, required this.containerId});

  @override
  State<Download> createState() => _DownloadState();
}

class _DownloadState extends State<Download> {
  final _containerIdController = TextEditingController();
  final _filePathController = TextEditingController();
  StreamSubscription<double>? _progressListner;
  String? _error;
  String? _progress;

  Future<void> _handleDownload() async {
    try {
      setState(() {
        _progress = 'Download Started';
        _error = null;
      });

      await ICloudStorage.download(
        containerId: _containerIdController.text,
        relativePath: _filePathController.text,
        onProgress: (stream) {
          _progressListner = stream.listen(
            (progress) => setState(() {
              _progress = 'Download Progress: $progress';
            }),
            onDone: () => setState(() {
              _progress = 'Download Completed';
            }),
            onError: (err) => setState(() {
              _error = getErrorMessage(err);
              _progress = '';
            }),
            cancelOnError: true,
          );
        },
      );
    } catch (ex) {
      setState(() {
        _progress = '';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('download example'),
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
                  labelText: 'relativePath',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handleDownload,
                child: const Text('DOWNLOAD'),
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
