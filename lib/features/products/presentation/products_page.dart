import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../alerts/warranty_alert_service.dart';
import '../../auth/domain/auth_service.dart';
import '../../categories/domain/category.dart';
import '../../categories/presentation/categories_page.dart';
import '../data/product_repository.dart';
import '../domain/product.dart';
import 'product_form_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ProductRepository _repository = ProductRepository();
  final WarrantyAlertService _alertService = WarrantyAlertService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _repository.seedDefaultCategories();
    _alertService.initialize();
    _repository.syncIfNeeded();
  }

  Future<void> _deleteProduct(Product product) async {
    await _repository.deleteProduct(product.id);
    await _alertService.cancelAlertsForProduct(product.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Garantir - Produtos'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const CategoriesPage()),
              );
            },
            icon: const Icon(Icons.category_outlined),
          ),
          IconButton(
            onPressed: () async => _authService.signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: StreamBuilder<List<ProductCategory>>(
        stream: _repository.watchCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar categorias: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = {
            for (final item in snapshot.data!) item.id: item.name,
          };

          return StreamBuilder<List<Product>>(
            stream: _repository.watchProducts(),
            builder: (context, productSnapshot) {
              if (productSnapshot.hasError) {
                return Center(
                  child: Text('Erro ao carregar produtos: ${productSnapshot.error}'),
                );
              }

              if (!productSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final products = productSnapshot.data!;
              if (products.isEmpty) {
                return const Center(
                  child: Text('Nenhum produto cadastrado ainda.'),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _ProductTile(
                    product: product,
                    categoryName: categories[product.categoryId] ?? 'Sem categoria',
                    onEdit: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ProductFormPage(existing: product),
                        ),
                      );
                    },
                    onDelete: () => _deleteProduct(product),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: products.length,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const ProductFormPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo produto'),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.categoryName,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final String categoryName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');
    final expired = product.isExpired;

    return Card(
      child: ListTile(
        title: Text(product.name),
        subtitle: Text(
          'Categoria: $categoryName\nGarantia: ${product.guaranteeType.label} - Vence em ${formatter.format(product.warrantyEndDate)}',
        ),
        isThreeLine: true,
        trailing: Wrap(
          spacing: 8,
          children: [
            if (expired)
              const Icon(Icons.warning_amber_rounded, color: Colors.red),
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline)),
          ],
        ),
      ),
    );
  }
}
