import 'package:flutter/material.dart';
import '../models/order_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final SupabaseClient cloud = Supabase.instance.client;

class OrderCard extends StatefulWidget {
  final OrderItem order;
  const OrderCard({super.key, required this.order});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool _isLoading = false;

  Map<String, dynamic> _getAction() {
    switch (widget.order.status) {
      case 'New':
        return {'text': 'Start processing', 'next': 'In preparation', 'color': Color(0xFF056B4C)};
      case 'In preparation':
        return {'text': 'Processing completed', 'next': 'ready', 'color': Color(0xFFE59D1B)};
      case 'ready':
        return {'text': 'Delivered', 'next': 'complete', 'color': Color(0xFF9FCCD5)};
      default:
        return {'text': 'complete', 'next': 'complete', 'color': Colors.grey};
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() { _isLoading = true; });
    try {
      await cloud.from('orders').update({'status': newStatus}).eq('id', widget.order.id);
    } catch (e) {
      print('Error updating order: $e');
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final action = _getAction();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(widget.order.orderId, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(widget.order.status, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
              ),
            ]),
            const SizedBox(height: 8),
            Text('Client: ${widget.order.customerName}'),
            const SizedBox(height: 4),
            Text('Total: ${widget.order.total.toStringAsFixed(2)} \$', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
              width: double.infinity,
              child: Text('Order details:\n${widget.order.details}', style: const TextStyle(fontSize: 14)),
            ),
            const SizedBox(height: 16),
            if (widget.order.status != 'complete')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _updateStatus(action['next']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: action['color'],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(action['text'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
