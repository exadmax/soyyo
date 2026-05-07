import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class InvoiceStorageService {
  InvoiceStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadInvoiceImage({
    required String productId,
    required XFile image,
  }) async {
    final bytes = await image.readAsBytes();
    final extension = image.path.contains('.')
        ? image.path.split('.').last.toLowerCase()
        : 'jpg';

    final ref = _storage
        .ref()
        .child('invoices')
        .child(productId)
        .child('invoice.$extension');

    final metadata = SettableMetadata(
      contentType: 'image/$extension',
      customMetadata: {'productId': productId},
    );

    await ref.putData(bytes, metadata);
    return ref.getDownloadURL();
  }
}
