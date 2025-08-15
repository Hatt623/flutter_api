import 'package:flutter/material.dart';
import 'package:flutter_api/models/order_model.dart';
import 'package:flutter_api/services/order_services.dart';
import 'package:flutter_api/pages/order&event/edit_order.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatefulWidget {
  final DataOrder order;

  const OrderDetailScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isLoading = false;

  Future<void> _deleteOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus order"),
        content: Text('Yakin ingin menghapus "${widget.order.name}"?'),
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
      final success = await OrderService.deleteOrder(widget.order.id!);
      if (success && mounted) {
        Navigator.pop(context, 'deleted');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('order berhasil dihapus')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) =>
      DateFormat('dd/MM/yyyy HH:mm').format(date);

  // Use Tiket dari order_model.dart
  void _showTicketDialog(List<Tiket> tikets) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Daftar Tiket"),
        content: tikets.isEmpty
            ? const Text("Tidak ada tiket untuk order ini.")
            : SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: tikets.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final t = tikets[index];
                    return ListTile(
                      leading: const Icon(Icons.confirmation_num_outlined),
                      title: Text(t.name ?? 'Tiket ${index + 1}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Kode: ${t.code ?? '-'}"),
                          if (t.startDate != null)
                            Text("Mulai: ${_formatDate(t.startDate!)}"),
                          if (t.endDate != null)
                            Text("Selesai: ${_formatDate(t.endDate!)}"),
                        ],
                      ),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.order.event;
    final isCancelled = widget.order.status?.toLowerCase() == 'cancelled';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.order.name ?? 'Detail order'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : () => _deleteOrder(),
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (event?.image != null && event!.image!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'http://127.0.0.1:8000/storage/${event.image!}',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, size: 100),
              ),
            ),
          const SizedBox(height: 16),

          if (isCancelled)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.cancel, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text(
                    'Status: Cancelled',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          Text(
            widget.order.name ?? 'Nama order',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18),
              const SizedBox(width: 4),
              Text(widget.order.location ?? 'Lokasi tidak tersedia'),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 18),
              const SizedBox(width: 4),
              Text('Mulai: ${_formatDate(event!.startDate!)}'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18),
              const SizedBox(width: 4),
              Text('Selesai: ${_formatDate(event.endDate!)}'),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            event.description ?? 'Tidak ada deskripsi',
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),

          const SizedBox(height: 20),

          // Tombol Lihat Tiket
          ElevatedButton.icon(
            icon: const Icon(Icons.confirmation_num),
            label: const Text("Lihat Tiket"),
            onPressed: () {
              _showTicketDialog(widget.order.tikets);
            },
          ),
        ],
      ),
      floatingActionButton: isCancelled
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditOrderScreen(order: widget.order),
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