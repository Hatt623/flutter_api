import 'package:flutter/material.dart';
import 'package:flutter_api/models/event_model.dart';
import 'package:flutter_api/pages/event/edit_event.dart';
import 'package:flutter_api/services/event_services.dart';
import 'package:flutter_api/services/order_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class EventDetailScreen extends StatefulWidget {
  final DataEvent event;

  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isLoading = false;

  Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? 0;
  }

  String generateOrderCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    final randomPart =
        List.generate(8, (index) => chars[rand.nextInt(chars.length)]).join();
    return 'ORD-$randomPart';
  }

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
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
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

  Future<void> _createOrder(BuildContext context) async {
    final rootCtx = context;
    bool isSubmitting = false;
    final event = widget.event;

    int quantity = 1;
    double bayar = 0;

    await showDialog(
      context: rootCtx,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setState) => AlertDialog(
            title: const Text('Konfirmasi Order'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Event: ${event.name}',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      'Tanggal: ${DateFormat('dd/MM/yyyy').format(event.startDate!)} - ${DateFormat('dd/MM/yyyy').format(event.endDate!)}'),
                  Text('Lokasi: ${event.location ?? '-'}'),
                  Text('Deskripsi: ${event.description ?? '-'}'),
                  Text('Harga Satuan: Rp ${event.price ?? 0}'),
                  const SizedBox(height: 16),

                  // Input Quantity
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      quantity = int.tryParse(val) ?? 1;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Input Bayar
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah Bayar',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      bayar = double.tryParse(val) ?? 0;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        setState(() => isSubmitting = true);

                        final hargaEvent = event.price ?? 0;
                        final totalHarusBayar =
                            hargaEvent * quantity;

                        if (bayar != totalHarusBayar) {
                          setState(() => isSubmitting = false);
                          ScaffoldMessenger.of(rootCtx).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Jumlah bayar harus tepat: Rp$totalHarusBayar'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }

                        try {
                          final userId = await getUserId();
                          final code = generateOrderCode();

                          await OrderService.createOrder(
                            event.name ?? '',
                            DateFormat('yyyy-MM-dd')
                                .format(event.startDate!),
                            DateFormat('yyyy-MM-dd')
                                .format(event.endDate!),
                            event.location ?? '',
                            event.description ?? '',
                            hargaEvent,
                            userId,
                            event.id!,
                            code,
                            quantity,
                            'paid',
                          );

                          Navigator.of(dialogCtx).pop();

                          ScaffoldMessenger.of(rootCtx).showSnackBar(
                            const SnackBar(
                              content: Text('Bayar sukses'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          Navigator.of(dialogCtx).pop();
                          ScaffoldMessenger.of(rootCtx).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Terjadi kesalahan saat membuat order'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Buat Order'),
              ),
            ],
          ),
        );
      },
    );
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
          IconButton(
            icon: const Icon(Icons.local_activity),
            color: const Color.fromARGB(255, 255, 64, 64), 
            tooltip: 'Beli Tiket',
            onPressed: () => _createOrder(context),
          )

        ],
        
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.event.image != null &&
              widget.event.image!.isNotEmpty)
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
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold),
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
              Text(
                  'Mulai: ${_formatDate(widget.event.startDate!)}'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18),
              const SizedBox(width: 4),
              Text(
                  'Selesai: ${_formatDate(widget.event.endDate!)}'),
            ],
          ),
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
              builder: (_) =>
                  EditEventScreen(event: widget.event),
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