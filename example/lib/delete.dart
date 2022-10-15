import 'dart:async';
import 'package:flutter/material.dart';
import 'package:icloud_storage/icloud_storage.dart';
import 'utils.dart';

class Delete extends StatefulWidget {
  final String containerId;

  const Delete({super.key, required this.containerId});

  @override
  State<Delete> createState() => _DeleteState();
}

class _DeleteState extends State<Delete> {
  final _containerIdController = TextEditingController();
  final _relativePathController = TextEditingController();
  String? _error;
  String? _progress;

  Future<void> _handleDelete() async {
    try {
      setState(() {
        _error = null;
        _progress = 'Delete Started';
      });

      await ICloudStorage.delete(
        containerId: _containerIdController.text,
        relativePath: _relativePathController.text,
      );

      setState(() {
        _progress = 'Delete Completed';
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
    _relativePathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('delete example'),
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handleDelete,
                child: const Text('DELETE'),
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
