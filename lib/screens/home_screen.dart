import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/warranty.dart';
import '../services/notification_service.dart';
import '../widgets/warranty_card.dart';
import 'add_edit_warranty_screen.dart';
import 'warranty_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  List<Warranty> _warranties = [];
  List<Warranty> _filtered = [];
  bool _loading = true;
  String _searchQuery = '';
  int _filterIndex = 0; // 0=Todas, 1=Válidas, 2=Vencendo, 3=Vencidas

  @override
  void initState() {
    super.initState();
    _loadWarranties();
  }

  Future<void> _loadWarranties() async {
    setState(() => _loading = true);
    final warranties = await _db.getAllWarranties();
    setState(() {
      _warranties = warranties;
      _applyFilter();
      _loading = false;
    });
  }

  void _applyFilter() {
    List<Warranty> result = _warranties;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((w) =>
              w.productName.toLowerCase().contains(q) ||
              w.brand.toLowerCase().contains(q))
          .toList();
    }
    switch (_filterIndex) {
      case 1:
        result =
            result.where((w) => !w.isExpired && !w.isExpiringSoon).toList();
        break;
      case 2:
        result = result.where((w) => w.isExpiringSoon && !w.isExpired).toList();
        break;
      case 3:
        result = result.where((w) => w.isExpired).toList();
        break;
    }
    _filtered = result;
  }

  Future<void> _deleteWarranty(Warranty warranty) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir garantia'),
        content:
            Text('Deseja excluir a garantia de ${warranty.productName}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _db.deleteWarranty(warranty.id);
      await NotificationService.cancelWarrantyNotification(warranty.id);
      _loadWarranties();
    }
  }

  @override
  Widget build(BuildContext context) {
    final expiringSoon =
        _warranties.where((w) => w.isExpiringSoon && !w.isExpired).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SoyYo – Garantias'),
        centerTitle: false,
        actions: [
          if (expiringSoon > 0)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_active),
                  tooltip: '$expiringSoon vencendo em breve',
                  onPressed: () {
                    setState(() {
                      _filterIndex = 2;
                      _applyFilter();
                    });
                  },
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$expiringSoon',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar produto ou marca...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (v) {
                setState(() {
                  _searchQuery = v;
                  _applyFilter();
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _FilterChip(
                    label: 'Todas',
                    selected: _filterIndex == 0,
                    onTap: () => setState(() {
                          _filterIndex = 0;
                          _applyFilter();
                        })),
                _FilterChip(
                    label: 'Válidas',
                    selected: _filterIndex == 1,
                    color: Colors.green,
                    onTap: () => setState(() {
                          _filterIndex = 1;
                          _applyFilter();
                        })),
                _FilterChip(
                    label: 'Vencendo',
                    selected: _filterIndex == 2,
                    color: Colors.orange,
                    onTap: () => setState(() {
                          _filterIndex = 2;
                          _applyFilter();
                        })),
                _FilterChip(
                    label: 'Vencidas',
                    selected: _filterIndex == 3,
                    color: Colors.red,
                    onTap: () => setState(() {
                          _filterIndex = 3;
                          _applyFilter();
                        })),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_rounded,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text(
                              _warranties.isEmpty
                                  ? 'Nenhuma garantia cadastrada'
                                  : 'Nenhum resultado encontrado',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadWarranties,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: _filtered.length,
                          itemBuilder: (ctx, i) {
                            final w = _filtered[i];
                            return WarrantyCard(
                              warranty: w,
                              onTap: () async {
                                await Navigator.push(
                                  ctx,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        WarrantyDetailScreen(warranty: w),
                                  ),
                                );
                                _loadWarranties();
                              },
                              onDelete: () => _deleteWarranty(w),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final warranty = await Navigator.push<Warranty>(
            context,
            MaterialPageRoute(
                builder: (_) => const AddEditWarrantyScreen()),
          );
          if (warranty != null && mounted) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WarrantyDetailScreen(warranty: warranty),
              ),
            );
          }
          _loadWarranties();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Garantia'),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        selectedColor: c.withOpacity(0.2),
        checkmarkColor: c,
        labelStyle: TextStyle(
          color: selected ? c : Colors.grey[700],
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}
