import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../alerts/warranty_alert_service.dart';
import '../../categories/domain/category.dart';
import '../data/invoice_storage_service.dart';
import '../data/product_repository.dart';
import '../domain/guarantee_type.dart';
import '../domain/product.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key, this.existing});

  final Product? existing;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = ProductRepository();
  final _invoiceStorageService = InvoiceStorageService();
  final _alertService = WarrantyAlertService();
  final _uuid = const Uuid();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _purchaseDate = DateTime.now();
  DateTime _warrantyEndDate = DateTime.now().add(const Duration(days: 365));
  GuaranteeType _guaranteeType = GuaranteeType.standard;
  String? _noteImageUrl;
  String? _selectedCategoryId;
  XFile? _selectedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _nameController.text = existing.name;
      _selectedCategoryId = existing.categoryId;
      _descriptionController.text = existing.description ?? '';
      _purchaseDate = existing.purchaseDate;
      _warrantyEndDate = existing.warrantyEndDate;
      _guaranteeType = existing.guaranteeType;
      _noteImageUrl = existing.noteImageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickInvoiceImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return;
    }
    setState(() {
      _selectedImage = image;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final productId = widget.existing?.id ?? _uuid.v4();
      var noteUrl = _noteImageUrl;

      if (_selectedImage != null) {
        noteUrl = await _invoiceStorageService.uploadInvoiceImage(
          productId: productId,
          image: _selectedImage!,
        );
      }

      final product = Product(
        id: productId,
        name: _nameController.text.trim(),
        categoryId: _selectedCategoryId!,
        purchaseDate: _purchaseDate,
        warrantyEndDate: _warrantyEndDate,
        guaranteeType: _guaranteeType,
        noteImageUrl: noteUrl,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      await _repository.saveProduct(product);
      await _alertService.scheduleWarrantyAlerts(
        productId: productId,
        productName: product.name,
        warrantyEndDate: product.warrantyEndDate,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar produto: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Novo produto' : 'Editar produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do produto'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome do produto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<ProductCategory>>(
                stream: _repository.watchCategories(),
                builder: (context, snapshot) {
                  final categories = snapshot.data ?? const <ProductCategory>[];

                  return DropdownButtonFormField<String>(
                    value: categories.any((item) => item.id == _selectedCategoryId)
                        ? _selectedCategoryId
                        : null,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    items: categories
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecione uma categoria';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<GuaranteeType>(
                value: _guaranteeType,
                decoration: const InputDecoration(labelText: 'Tipo de garantia'),
                items: GuaranteeType.values
                    .map(
                      (item) => DropdownMenuItem<GuaranteeType>(
                        value: item,
                        child: Text(item.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _guaranteeType = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data da compra'),
                subtitle: Text('${_purchaseDate.day}/${_purchaseDate.month}/${_purchaseDate.year}'),
                trailing: const Icon(Icons.calendar_month_outlined),
                onTap: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: _purchaseDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (selected != null) {
                    setState(() {
                      _purchaseDate = selected;
                    });
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data de vencimento da garantia'),
                subtitle: Text('${_warrantyEndDate.day}/${_warrantyEndDate.month}/${_warrantyEndDate.year}'),
                trailing: const Icon(Icons.event_busy_outlined),
                onTap: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: _warrantyEndDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (selected != null) {
                    setState(() {
                      _warrantyEndDate = selected;
                    });
                  }
                },
              ),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observacoes',
                  hintText: 'Detalhes extras da garantia',
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickInvoiceImage,
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(
                  _selectedImage == null && _noteImageUrl == null
                      ? 'Adicionar foto da nota fiscal'
                      : 'Nota fiscal vinculada',
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: Text(_isSaving ? 'Salvando...' : 'Salvar produto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
