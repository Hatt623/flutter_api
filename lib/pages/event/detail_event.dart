import 'package:flutter/material.dart';
import 'package:flutter_api/models/event_model.dart';
import 'package:flutter_api/pages/event/edit_event.dart';
import 'package:flutter_api/services/event_services.dart';
import 'package:intl/intl.dart';

class EventDetailScreen extends StatefulWidget {
  final DataEvent event;

  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isLoading = false;

  Future<void> _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Event"),
        content: Text('Yakin ingin menghapus "${widget.event.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      final success = await EventService.deleteEvent(widget.event.id!);
      if (success && mounted) {
        Navigator.pop(context, 'deleted');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event berhasil dihapus')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) =>
      DateFormat('dd/MM/yyyy HH:mm').format(date);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.name ?? 'Detail Event'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : () => _deleteEvent(),
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.event.image != null && widget.event.image!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'http://127.0.0.1:8000/storage/${widget.event.image!}',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, size: 100),
              ),
            ),
          const SizedBox(height: 16),

          Text(
            widget.event.name ?? 'Nama Event',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18),
              const SizedBox(width: 4),
              Text(widget.event.location ?? 'Lokasi tidak tersedia'),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 18),
              const SizedBox(width: 4),
              Text('Mulai: ${_formatDate(widget.event.startDate!)}'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18),
              const SizedBox(width: 4),
              Text('Selesai: ${_formatDate(widget.event.endDate!)}'),
            ],
          ),
          const SizedBox(height: 16),

          // Chip(
          //   label: Text(widget.event.status == 1 ? "Aktif" : "Tidak Aktif"),
          //   backgroundColor: widget.event.status == 1
          //       ? Colors.greenAccent
          //       : Colors.grey.shade300,
          // ),
          const SizedBox(height: 16),

          Text(
            widget.event.description ?? 'Tidak ada deskripsi',
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditEventScreen(event: widget.event),
            ),
          );

          if (result == true && mounted) {
            Navigator.pop(context, true);
          }
        },
      ),
    );
  }
}