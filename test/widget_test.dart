import 'package:flutter_test/flutter_test.dart';
import 'package:soyyo/app/app.dart';

void main() {
  testWidgets('Renderiza tela principal', (tester) async {
    await tester.pumpWidget(const SoyYoApp());
    expect(find.text('Garantir - Produtos'), findsOneWidget);
  });
}
