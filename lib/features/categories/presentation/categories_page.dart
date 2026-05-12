import 'package:flutter/material.dart';

import '../../products/data/product_repository.dart';
import '../domain/category.dart';

const _brand  = Color(0xFF1F6E8C);
const _bg     = Color(0xFFF4F6F8);
const _border = Color(0xFFEEF1F4);
const _muted  = Color(0xFF6B7785);
const _dark   = Color(0xFF1A1F26);

String _catEmoji(String name) {
  final n = name.toLowerCase()
      .replaceAll(RegExp('[áàâãä]'), 'a').replaceAll(RegExp('[éèêë]'), 'e')
      .replaceAll(RegExp('[íìîï]'), 'i').replaceAll(RegExp('[óòôõö]'), 'o')
      .replaceAll(RegExp('[úùûü]'), 'u').replaceAll('ç', 'c');
  if (n.contains('eletrodom')) return '🔌';
  if (n.contains('eletr') || n.contains('celular')) return '📱';
  if (n.contains('veiculo') || n.contains('carro') || n.contains('auto')) return '🚗';
  if (n.contains('ferram')) return '🔧';
  if (n.contains('movel') || n.contains('sofa')) return '🛋';
  if (n.contains('servic')) return '🛠️';
  if (n.contains('esporte') || n.contains('sport')) return '⚽';
  if (n.contains('vestua') || n.contains('roupa')) return '👕';
  return '🏷️';
}

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final ProductRepository _repo = ProductRepository();

  Future<void> _showAddSheet() async {
    final ctrl = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Nova categoria', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _dark)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Nome da categoria',
                hintText: 'Ex: Eletrodomésticos',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _brand, width: 1.5),
                ),
              ),
              onSubmitted: (_) async {
                final name = ctrl.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(ctx);
                await _repo.saveCategory(ProductCategory(id: '', name: name));
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _brand,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final name = ctrl.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(ctx);
                await _repo.saveCategory(ProductCategory(id: '', name: name));
              },
              child: const Text('Adicionar', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ]),
        );
      },
    );
    ctrl.dispose();
  }

  Future<void> _confirmDelete(ProductCategory cat) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir categoria'),
        content: Text('Excluir "${cat.name}"? Produtos vinculados perderão a categoria.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE05555)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await _repo.deleteCategory(cat.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: _dark),
        title: const Text('Categorias', style: TextStyle(color: _dark, fontWeight: FontWeight.w700)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _showAddSheet,
              style: FilledButton.styleFrom(
                backgroundColor: _brand,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nova', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<ProductCategory>>(
        stream: _repo.watchCategories(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final all = snap.data!;
          if (all.isEmpty) {
            return const Center(
              child: Text('Nenhuma categoria cadastrada.', style: TextStyle(color: _muted)),
            );
          }
          final custom   = all.where((c) => !c.isDefault).toList();
          final defaults = all.where((c) => c.isDefault).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (custom.isNotEmpty) ...[
                _GroupLabel('PERSONALIZADAS (${custom.length})'),
                const SizedBox(height: 8),
                ...custom.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _CategoryTile(cat: c, onDelete: () => _confirmDelete(c)),
                )),
                const SizedBox(height: 16),
              ],
              _GroupLabel('PADRÃO (${defaults.length})'),
              const SizedBox(height: 8),
              ...defaults.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _CategoryTile(cat: c, onDelete: null),
              )),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        backgroundColor: _brand,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _muted, letterSpacing: 0.8),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.cat, required this.onDelete});
  final ProductCategory cat;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(_catEmoji(cat.name), style: const TextStyle(fontSize: 20)),
        ),
        title: Text(cat.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _dark)),
        trailing: cat.isDefault
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1F5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text('PADRÃO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _brand)),
              )
            : IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFFE05555), size: 20),
                tooltip: 'Excluir',
                onPressed: onDelete,
              ),
      ),
    );
  }
}
