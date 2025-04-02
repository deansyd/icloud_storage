import 'dart:async';
import 'package:flutter/material.dart';
import 'package:icloud_storage/icloud_storage.dart';
import 'utils.dart';

class Gather extends StatefulWidget {
  const Gather({super.key});

  @override
  State<Gather> createState() => _GatherState();
}

class _GatherState extends State<Gather> {
  final _containerIdController = TextEditingController(text: "iCloud.test");
  StreamSubscription<List<ICloudFile>>? _updateListner;

  List<ICloudFile> _files = [];
  String? _error;
  String _status = '';

  Future<void> _handleGather() async {
    setState(() {
      _status = 'busy';
    });

    try {
      final results = await ICloudStorage.gather(
        containerId: _containerIdController.text,
        onUpdate: (stream) {
          _updateListner = stream.listen((updatedFileList) {
            setState(() {
              _files = updatedFileList;
            });
          });
        },
      );

      setState(() {
        _status = 'listening';
        _error = null;
        _files = results;
      });
    } catch (ex) {
      setState(() {
        _error = getErrorMessage(ex);
        _status = '';
      });
    }
  }

  Future<void> _cancel() async {
    await _updateListner?.cancel();
    setState(() {
      _status = '';
    });
  }

  @override
  void dispose() {
    _updateListner?.cancel();
    _containerIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('icloud_storage example'),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) => const [
              PopupMenuItem(
                value: '/upload',
                child: Text('Upload'),
              ),
              PopupMenuItem(
                value: '/download',
                child: Text('Download'),
              ),
              PopupMenuItem(
                value: '/delete',
                child: Text('Delete'),
              ),
              PopupMenuItem(
                value: '/move',
                child: Text('Move'),
              ),
              PopupMenuItem(
                value: '/rename',
                child: Text('Rename'),
              ),
            ],
            onSelected: (value) => Navigator.pushNamed(
              context,
              value,
              arguments: _containerIdController.text,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _containerIdController,
                decoration: const InputDecoration(
                  labelText: 'containerId',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _status == ''
                    ? _handleGather
                    : _status == 'listening'
                        ? _cancel
                        : null,
                child: Text(
                  _status == ''
                      ? 'GATHER'
                      : _status == 'busy'
                          ? 'GATHERING'
                          : 'STOP LISTENING TO UPDATE',
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    if (_error != null)
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    for (final file in _files)
                      ListTile(
                        title: Text(file.relativePath),
                        subtitle: Text("Changed: ${file.contentChangeDate}"),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
