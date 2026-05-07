enum GuaranteeType {
  standard,
  extended,
  maintenance,
}

extension GuaranteeTypeExtension on GuaranteeType {
  String get label {
    switch (this) {
      case GuaranteeType.standard:
        return 'Padrao';
      case GuaranteeType.extended:
        return 'Estendida';
      case GuaranteeType.maintenance:
        return 'Manutencao';
    }
  }
}
