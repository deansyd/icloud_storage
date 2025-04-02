import 'dart:async';
import 'package:flutter/material.dart';
import 'package:icloud_storage/icloud_storage.dart';
import 'utils.dart';

class Move extends StatefulWidget {
  final String containerId;

  const Move({super.key, required this.containerId});

  @override
  State<Move> createState() => _MoveState();
}

class _MoveState extends State<Move> {
  final _containerIdController = TextEditingController(text: "iCloud.test");
  final _fromPathController = TextEditingController();
  final _toPathController = TextEditingController();
  String? _error;
  String? _progress;

  Future<void> _handleMove() async {
    try {
      setState(() {
        _error = null;
        _progress = 'Move Started';
      });

      await ICloudStorage.move(
        containerId: _containerIdController.text,
        fromRelativePath: _fromPathController.text,
        toRelativePath: _toPathController.text,
      );

      setState(() {
        _progress = 'Move Completed';
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
    _fromPathController.dispose();
    _toPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('move example'),
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
                controller: _fromPathController,
                decoration: const InputDecoration(
                  labelText: 'fromRelativePath',
                ),
              ),
              TextField(
                controller: _toPathController,
                decoration: const InputDecoration(
                  labelText: 'toRelativePath',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handleMove,
                child: const Text('MOVE'),
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
