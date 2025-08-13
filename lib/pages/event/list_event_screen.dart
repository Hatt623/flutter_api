// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_api/models/event_model.dart';
import 'package:flutter_api/pages/event/create_event.dart';
import 'package:flutter_api/services/event_services.dart';
import 'package:flutter_api/pages/event/detail_event.dart';

class ListEventScreen extends StatefulWidget {
  const ListEventScreen({super.key});

  @override
  State<ListEventScreen> createState() => _ListEventScreenState();
}

class _ListEventScreenState extends State<ListEventScreen> {
  late Future<EventModel> _futureEvents;

  @override
  void initState() {
    super.initState();
    _futureEvents = EventService.listEvents();
  }

  void _refreshEvent() {
    setState(() {
      _futureEvents = EventService.listEvents();
    });
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';

    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }

    if (date is String) {
      final d = DateTime.tryParse(date);
      if (d != null) {
        return '${d.day}/${d.month}/${d.year}';
      }
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
        title: const Text('My event'),
        actions: [
          IconButton(onPressed: _refreshEvent, icon: const Icon(Icons.refresh)),
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateEventScreen()),
              );
              if (result == true) _refreshEvent();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder<EventModel>(
        future: _futureEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final events = snapshot.data?.data ?? [];
          if (events.isEmpty) {
            return const Center(child: Text('No event found'));
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailScreen(event: event),
                      ),
                    );
                    if (result == true) _refreshEvent();
                  },
                  leading: event.image != null && event.image!.isNotEmpty
                      ? Image.network(
                          'http://127.0.0.1:8000/storage/${event.image!}',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        )
                      : const Icon(Icons.article),
                  title: Text(event.name ?? 'No Title'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (event.location != null && event.location!.isNotEmpty)
                        Text(
                          event.location!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        '${_formatDate(event.startDate)} To ${_formatDate(event.endDate)}',
                        style: TextStyle(
                          color: _isStartAfterEnd(event.startDate, event.endDate)
                              ? Colors.red
                              : Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text('#${event.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}