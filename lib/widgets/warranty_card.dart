import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/warranty.dart';

class WarrantyCard extends StatelessWidget {
  final Warranty warranty;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const WarrantyCard({
    super.key,
    required this.warranty,
    required this.onTap,
    required this.onDelete,
  });

  Color _statusColor() {
    if (warranty.isExpired) return Colors.red;
    if (warranty.isExpiringSoon) return Colors.orange;
    return Colors.green;
  }

  String _statusLabel() {
    if (warranty.isExpired) return 'Vencida';
    if (warranty.isExpiringSoon) {
      return 'Vence em ${warranty.daysUntilExpiry} dias';
    }
    return 'Válida';
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final statusColor = _statusColor();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.4), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.verified_user_rounded,
                  color: statusColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      warranty.productName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      warranty.brand,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _statusLabel(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.calendar_today,
                            size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          dateFormat.format(warranty.expirationDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (warranty.imagePaths.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(Icons.photo_library,
                      size: 18, color: Colors.grey[400]),
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: onDelete,
                tooltip: 'Excluir',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
