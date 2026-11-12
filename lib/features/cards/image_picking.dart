import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Lets the user choose a picture for a card face.
abstract interface class ImagePicking {
  /// Path of a temporary copy of the chosen picture, or `null` when the user
  /// cancelled. The card service copies it into the image store on save.
  Future<String?> pick();
}

/// Picks from the phone gallery; replaced by a fake in tests.
final imagePickingProvider = Provider<ImagePicking>(
  (ref) => const GalleryImagePicking(),
);

/// Picks a picture from the phone gallery, scaled down so that a card image
/// stays light in storage, in notifications and in an export.
class GalleryImagePicking implements ImagePicking {
  const GalleryImagePicking();

  static const double _maxSide = 1600;

  @override
  Future<String?> pick() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: _maxSide,
      maxHeight: _maxSide,
      imageQuality: 85,
    );
    return picked?.path;
  }
}
