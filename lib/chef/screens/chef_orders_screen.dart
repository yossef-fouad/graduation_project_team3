import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_item.dart';
import '../widgets/order_card.dart';

final SupabaseClient cloud = Supabase.instance.client;

class ChefOrdersScreen extends StatefulWidget {
  const ChefOrdersScreen({super.key});
  @override
  State<ChefOrdersScreen> createState() => _ChefOrdersScreenState();
}

class _ChefOrdersScreenState extends State<ChefOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> statuses = ['New', 'In preparation', 'ready', 'complete'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: statuses.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<List<OrderItem>> _fetchOrdersStream() {
    return cloud
        .from('orders')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .execute()
        .map((response) => (response as List).map((json) => OrderItem.fromJson(json)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chef control panel', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          indicatorWeight: 4,
          tabs: statuses.map((s) => Tab(text: s)).toList(),
        ),
      ),
      body: StreamBuilder<List<OrderItem>>(
        stream: _fetchOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ في جلب الطلبات: ${snapshot.error}'));
          }

          final allOrders = snapshot.data ?? [];

          return TabBarView(
            controller: _tabController,
            children: statuses.map((status) {
              final filtered = allOrders.where((o) => o.status == status).toList();
              if (filtered.isEmpty) {
                return Center(child: Text('No requests in case "$status"'));
              }
              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (c, i) => OrderCard(order: filtered[i]),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
