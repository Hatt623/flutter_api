import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_api/models/event_model.dart';
import 'package:flutter_api/services/event_services.dart';
import 'package:intl/intl.dart';

class EditEventScreen extends StatefulWidget {
  final DataEvent event;
  const EditEventScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  DateTime? _startDate;
  DateTime? _endDate;
  Uint8List? _imageBytes;
  String? _imageName;
  bool _isLoading = false;
  bool _isImageChanged = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event.name ?? '');
    _locationController = TextEditingController(text: widget.event.location ?? '');
    _descriptionController = TextEditingController(text: widget.event.description ?? '');
    _startDate = widget.event.startDate;
    _endDate = widget.event.endDate;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = image.name;
        _isImageChanged = true;
      });
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal mulai dan selesai wajib diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final price = int.tryParse(_priceController.text) ?? 0;

    final success = await EventService.updateEvent(
      widget.event.id!,
      _nameController.text,
      DateFormat('yyyy-MM-dd').format(_startDate!),
      DateFormat('yyyy-MM-dd').format(_endDate!),
      _locationController.text,
      _descriptionController.text,
      price,
      _isImageChanged ? _imageBytes : null,
      _isImageChanged ? _imageName : null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Event Updated' : 'Failed to Update Event'),
        backgroundColor: success ? Colors.greenAccent : Colors.redAccent,
      ),
    );

    if (success) Navigator.pop(context, true);
  }

  void _confirmDeleteEvent(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure? This action cannot be undone'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await EventService.deleteEvent(widget.event.id!);
              if (!mounted) return;
              setState(() => _isLoading = false);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? 'Event Deleted' : 'Failed to Delete Event'),
                  backgroundColor: success ? Colors.greenAccent : Colors.redAccent,
                ),
              );

              if (success) Navigator.pop(context, 'deleted');
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Event"),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : () => _confirmDeleteEvent(context),
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
                validator: (v) => v!.isEmpty ? 'Name Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (v) => v!.isEmpty ? 'Location Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => v!.isEmpty ? 'Description Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    child: Text('From'),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _pickDate(isStart: true),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(_startDate != null
                          ? DateFormat('dd/MM/yyyy').format(_startDate!)
                          : 'Pick Start Date'),
                    ),
                  ),
                  Container(
                    child: Text('To'),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _pickDate(isStart: false),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(_endDate != null
                          ? DateFormat('dd/MM/yyyy').format(_endDate!)
                          : 'Pick End Date'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: _imageBytes != null
                      ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                      : (widget.event.image != null &&
                              'http://127.0.0.1:8000/storage/${widget.event.image!}'.isNotEmpty)
                          ? Image.network(
                              'http://127.0.0.1:8000/storage/${widget.event.image!}',
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image, size: 60, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateEvent,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Update Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}