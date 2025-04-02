import 'dart:async';
import 'package:flutter/material.dart';
import 'package:icloud_storage/icloud_storage.dart';
import 'utils.dart';

class Rename extends StatefulWidget {
  final String containerId;

  const Rename({super.key, required this.containerId});

  @override
  State<Rename> createState() => _RenameState();
}

class _RenameState extends State<Rename> {
  final _containerIdController = TextEditingController(text: "iCloud.test");
  final _relativePathController = TextEditingController();
  final _newNameController = TextEditingController();
  String? _error;
  String? _progress;

  Future<void> _handleRename() async {
    try {
      setState(() {
        _error = null;
        _progress = 'Rename Started';
      });

      await ICloudStorage.rename(
        containerId: _containerIdController.text,
        relativePath: _relativePathController.text,
        newName: _newNameController.text,
      );

      setState(() {
        _progress = 'Rename Completed';
      });
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
    _containerIdController.dispose();
    _newNameController.dispose();
    _relativePathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('rename example'),
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
                controller: _relativePathController,
                decoration: const InputDecoration(
                  labelText: 'relativePath',
                ),
              ),
              TextField(
                controller: _newNameController,
                decoration: const InputDecoration(
                  labelText: 'newName',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handleRename,
                child: const Text('RENAME'),
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
