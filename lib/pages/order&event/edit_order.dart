import 'package:flutter/material.dart';
import 'package:flutter_api/models/order_model.dart';
import 'package:flutter_api/services/order_services.dart';

class EditOrderScreen extends StatefulWidget {
  final DataOrder order;
  const EditOrderScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _status = widget.order.status ?? 'pending';
  }

  Future<void> _updateStatus() async {
    setState(() {
      _isLoading == true;
      _status = 'cancelled';
    });
    final success = await OrderService.updateOrder(
      widget.order.id!,
      _status,
    );

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success != null ? 'Order Cancelled' : 'Failed to cancel order'),
        backgroundColor: success != null ? Colors.redAccent : Colors.orangeAccent,
      ),
    );

    if (success != null && mounted) Navigator.pop(context, true);
  }

  Future<void> _confirmCancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembatalan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 48),
            SizedBox(height: 12),
            Text(
              'Apakah kamu yakin ingin membatalkan order tiket ini?',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _updateStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.order.event!;
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Order Status")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: widget.order.name,
                decoration: const InputDecoration(labelText: 'Order Name'),
                enabled: false,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: widget.order.location,
                decoration: const InputDecoration(labelText: 'Location'),
                enabled: false,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: widget.order.price?.toString(),
                decoration: const InputDecoration(labelText: 'Price'),
                enabled: false,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: event.name,
                decoration: const InputDecoration(labelText: 'Event'),
                enabled: false,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: 'cancelled',
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(
                    value: 'cancelled',
                    child: Text('CANCELLED'),
                  ),
                ],
                onChanged: null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _confirmCancel,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Cancel Order?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}