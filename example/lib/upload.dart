import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:icloud_storage/icloud_storage.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'utils.dart';

class Upload extends StatefulWidget {
  final String containerId;

  const Upload({super.key, required this.containerId});

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  final _containerIdController = TextEditingController(text: "iCloud.test");
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

      final String filePath = path.join(
          await getApplicationSupportDirectory().then((v) => v.path),
          _filePathController.text);

      File(filePath).setLastModifiedSync(DateTime.now());

      await ICloudStorage.upload(
        containerId: _containerIdController.text,
        filePath: filePath,
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
                decoration: InputDecoration(
                    labelText:
                        'filePath ( relative to applicationSupportDirectory )',
                    suffixIcon: IconButton(
                      icon: const Icon(CupertinoIcons.question_circle),
                      onPressed: () {
                        showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                                  title: const Text('filePath'),
                                  content: const Text(
                                      'Try f0, f1, f2, ..., f9 for testing if you don\'t have a file.'),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: const Text('OK'),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ));
                      },
                    )),
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
