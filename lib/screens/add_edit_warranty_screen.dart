import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../database/database_helper.dart';
import '../models/warranty.dart';
import '../services/notification_service.dart';
import '../services/photo_service.dart';
import '../widgets/photo_widget.dart';

class AddEditWarrantyScreen extends StatefulWidget {
  final Warranty? warranty;

  const AddEditWarrantyScreen({super.key, this.warranty});

  @override
  State<AddEditWarrantyScreen> createState() => _AddEditWarrantyScreenState();
}

class _AddEditWarrantyScreenState extends State<AddEditWarrantyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _serialCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime _purchaseDate = DateTime.now();
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 365));
  List<String> _imagePaths = [];
  bool _saving = false;

  static const Uuid _uuid = Uuid();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  bool get _isEditing => widget.warranty != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final w = widget.warranty!;
      _nameCtrl.text = w.productName;
      _brandCtrl.text = w.brand;
      _serialCtrl.text = w.serialNumber ?? '';
      _notesCtrl.text = w.notes ?? '';
      _purchaseDate = w.purchaseDate;
      _expirationDate = w.expirationDate;
      _imagePaths = List.from(w.imagePaths);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _serialCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isPurchase}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isPurchase ? _purchaseDate : _expirationDate,
      firstDate: isPurchase ? DateTime(2000) : now,
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() {
        if (isPurchase) {
          _purchaseDate = picked;
        } else {
          _expirationDate = picked;
        }
      });
    }
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
      setState(() => _imagePaths.add(imagePath!));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_expirationDate.isBefore(_purchaseDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'A data de vencimento deve ser posterior à data de compra.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    final warranty = Warranty(
      id: _isEditing ? widget.warranty!.id : _uuid.v4(),
      productName: _nameCtrl.text.trim(),
      brand: _brandCtrl.text.trim(),
      serialNumber:
          _serialCtrl.text.trim().isEmpty ? null : _serialCtrl.text.trim(),
      purchaseDate: _purchaseDate,
      expirationDate: _expirationDate,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      imagePaths: _imagePaths,
    );

    final db = DatabaseHelper();
    if (_isEditing) {
      await db.updateWarranty(warranty);
    } else {
      await db.insertWarranty(warranty);
    }

    await NotificationService.scheduleWarrantyNotification(warranty);

    if (!mounted) return;
    setState(() => _saving = false);

    Navigator.pop(context, warranty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Garantia' : 'Nova Garantia'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Salvar',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(title: 'Produto'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome do produto *',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _brandCtrl,
                decoration: const InputDecoration(
                  labelText: 'Marca *',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _serialCtrl,
                decoration: const InputDecoration(
                  labelText: 'Número de série (opcional)',
                  prefixIcon: Icon(Icons.tag_outlined),
                ),
              ),
              const SizedBox(height: 24),
              _SectionTitle(title: 'Datas'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'Data de compra',
                      date: _purchaseDate,
                      dateFormat: _dateFormat,
                      onTap: () => _pickDate(isPurchase: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: 'Vencimento',
                      date: _expirationDate,
                      dateFormat: _dateFormat,
                      onTap: () => _pickDate(isPurchase: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SectionTitle(title: 'Observações'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              _SectionTitle(title: 'Fotos da Nota Fiscal'),
              const SizedBox(height: 8),
              if (_imagePaths.isNotEmpty) ...[
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imagePaths.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: PhotoWidget(
                              imagePath: _imagePaths[i],
                              width: 100,
                              height: 110,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _imagePaths.removeAt(i)),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
              OutlinedButton.icon(
                onPressed: _addPhoto,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Adicionar foto'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final DateFormat dateFormat;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.dateFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(
          dateFormat.format(date),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
