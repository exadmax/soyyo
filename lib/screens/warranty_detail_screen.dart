import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/warranty.dart';
import '../services/notification_service.dart';
import '../services/photo_service.dart';
import '../widgets/photo_widget.dart';
import 'add_edit_warranty_screen.dart';

class WarrantyDetailScreen extends StatefulWidget {
  final Warranty warranty;

  const WarrantyDetailScreen({super.key, required this.warranty});

  @override
  State<WarrantyDetailScreen> createState() => _WarrantyDetailScreenState();
}

class _WarrantyDetailScreenState extends State<WarrantyDetailScreen> {
  late Warranty _warranty;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _warranty = widget.warranty;
  }

  Future<void> _refreshWarranty() async {
    final db = DatabaseHelper();
    final updated = await db.getWarrantyById(_warranty.id);
    if (updated != null && mounted) {
      setState(() => _warranty = updated);
    }
  }

  Color _statusColor() {
    if (_warranty.isExpired) return Colors.red;
    if (_warranty.isExpiringSoon) return Colors.orange;
    return Colors.green;
  }

  String _statusLabel() {
    if (_warranty.isExpired) return 'Garantia vencida';
    if (_warranty.isExpiringSoon) {
      return 'Vence em ${_warranty.daysUntilExpiry} dias';
    }
    return 'Garantia válida';
  }

  Future<void> _addPhoto() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tirar foto'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (action == null) return;

    String? imagePath;
    if (action == 'camera') {
      imagePath = await PhotoService.takePhoto();
    } else {
      imagePath = await PhotoService.pickFromGallery();
    }

    if (imagePath != null) {
      final updatedPaths = [..._warranty.imagePaths, imagePath];
      final updated = _warranty.copyWith(imagePaths: updatedPaths);
      await DatabaseHelper().updateWarranty(updated);
      setState(() => _warranty = updated);
    }
  }

  Future<void> _deletePhoto(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir foto'),
        content: const Text('Deseja excluir esta foto?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await PhotoService.deletePhoto(_warranty.imagePaths[index]);
    final updatedPaths = [..._warranty.imagePaths]..removeAt(index);
    final updated = _warranty.copyWith(imagePaths: updatedPaths);
    await DatabaseHelper().updateWarranty(updated);
    setState(() => _warranty = updated);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir garantia'),
        content:
            Text('Deseja excluir a garantia de ${_warranty.productName}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await PhotoService.deletePhotos(_warranty.imagePaths);
    await DatabaseHelper().deleteWarranty(_warranty.id);
    await NotificationService.cancelWarrantyNotification(_warranty.id);

    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return Scaffold(
      appBar: AppBar(
        title: Text(_warranty.productName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        AddEditWarrantyScreen(warranty: _warranty)),
              );
              await _refreshWarranty();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Excluir',
            onPressed: _delete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    _warranty.isExpired
                        ? Icons.cancel_outlined
                        : Icons.verified_user_rounded,
                    color: statusColor,
                    size: 36,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _statusLabel(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Vencimento: ${_dateFormat.format(_warranty.expirationDate)}',
                          style: TextStyle(
                              color: statusColor.withOpacity(0.8),
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _InfoSection(
              title: 'Informações do Produto',
              children: [
                _InfoRow(
                    icon: Icons.inventory_2_outlined,
                    label: 'Produto',
                    value: _warranty.productName),
                _InfoRow(
                    icon: Icons.business_outlined,
                    label: 'Marca',
                    value: _warranty.brand),
                if (_warranty.serialNumber != null)
                  _InfoRow(
                      icon: Icons.tag_outlined,
                      label: 'Nº de série',
                      value: _warranty.serialNumber!),
              ],
            ),
            const SizedBox(height: 16),
            _InfoSection(
              title: 'Datas',
              children: [
                _InfoRow(
                    icon: Icons.shopping_cart_outlined,
                    label: 'Compra',
                    value: _dateFormat.format(_warranty.purchaseDate)),
                _InfoRow(
                    icon: Icons.event_outlined,
                    label: 'Vencimento',
                    value: _dateFormat.format(_warranty.expirationDate)),
              ],
            ),
            if (_warranty.notes != null && _warranty.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _InfoSection(
                title: 'Observações',
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _warranty.notes!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Fotos da Nota Fiscal',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addPhoto,
                  icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
            if (_warranty.imagePaths.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_camera_outlined,
                        size: 40, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Nenhuma foto adicionada',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _warranty.imagePaths.length,
                itemBuilder: (_, i) {
                  return GestureDetector(
                    onTap: () => _openPhoto(i),
                    onLongPress: () => _deletePhoto(i),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: PhotoWidget(
                        imagePath: _warranty.imagePaths[i],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _openPhoto(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PhotoViewScreen(
          imagePaths: _warranty.imagePaths,
          initialIndex: index,
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[500]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey[500])),
                Text(value,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoViewScreen extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const _PhotoViewScreen(
      {required this.imagePaths, required this.initialIndex});

  @override
  State<_PhotoViewScreen> createState() => _PhotoViewScreenState();
}

class _PhotoViewScreenState extends State<_PhotoViewScreen> {
  late PageController _controller;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_current + 1} / ${widget.imagePaths.length}'),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.imagePaths.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (_, i) => InteractiveViewer(
          child: Center(
            child: PhotoWidget(
              imagePath: widget.imagePaths[i],
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
