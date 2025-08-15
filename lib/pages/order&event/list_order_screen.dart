import 'package:flutter/material.dart';
import 'package:flutter_api/models/order_model.dart'; // pastikan DataOrder ada di sini
import 'package:flutter_api/services/order_services.dart';
import 'package:flutter_api/pages/order&event/detail_order.dart';

class ListOrderScreen extends StatefulWidget {
  const ListOrderScreen({super.key});

  @override
  State<ListOrderScreen> createState() => _ListOrderScreenState();
}

class _ListOrderScreenState extends State<ListOrderScreen> {
    late Future<List<DataOrder>> _futureOrders;

    @override
    void initState() {
      super.initState();
      _futureOrders = OrderService.listOrders();
    }

    Future<void> _refreshOrder() async {
      setState(() {
        _futureOrders = OrderService.listOrders();
      });
      await _futureOrders;
    }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    if (date is DateTime) return '${date.day}/${date.month}/${date.year}';
    if (date is String) {
      final d = DateTime.tryParse(date);
      if (d != null) return '${d.day}/${d.month}/${d.year}';
    }
    return '';
  }

  bool _isStartAfterEnd(dynamic start, dynamic end) {
    final startDate = start is DateTime ? start : DateTime.tryParse(start.toString());
    final endDate = end is DateTime ? end : DateTime.tryParse(end.toString());
    if (startDate == null || endDate == null) return false;
    return startDate.isAfter(endDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Order & Tickets'),
        actions: [
          IconButton(onPressed: _refreshOrder, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<List<DataOrder>>(
        future: _futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final model = snapshot.data;
          List<DataOrder> orders = [];

          if (model is List<DataOrder>) {
            orders = model;
          } 

          if (orders.isEmpty) {
            return const Center(child: Text('No Order found'));
          }

          return RefreshIndicator(
          onRefresh: _refreshOrder,
          child: ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
                final event = order.event;
                final isCancelled = order.status?.toLowerCase() == 'cancelled';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    onTap: isCancelled
                        ? null
                        : () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderDetailScreen(order: order),
                              ),
                            );
                            if (result == true) _refreshOrder();
                          },
                    leading: event?.image != null && (event!.image?.isNotEmpty ?? false)
                        ? Image.network(
                            'http://127.0.0.1:8000/storage/${event.image!}',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                          )
                        : const Icon(Icons.article),
                    title: Text(order.name ?? 'No Title'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((order.location ?? '').isNotEmpty)
                          Text(
                            order.location!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text(
                          '${_formatDate(order.startDate)} To ${_formatDate(order.endDate)}',
                          style: TextStyle(
                            color: _isStartAfterEnd(order.startDate, order.endDate)
                                ? Colors.red
                                : Colors.green,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: isCancelled
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cancel, color: Colors.redAccent),
                              const SizedBox(width: 4),
                              const Text(
                                'CANCELLED',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Hapus Order'),
                                      content: Text('Yakin ingin menghapus "${order.name}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Batal'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                          ),
                                          child: const Text('Hapus'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true) {
                                    final success = await OrderService.deleteOrder(order.id!);
                                    if (success && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Order berhasil dihapus')),
                                      );
                                      _refreshOrder();
                                    }
                                  }
                                },
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}