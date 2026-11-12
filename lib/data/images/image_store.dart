import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// The images of the cards, copied into a folder of the app.
///
/// A card keeps the name of its image file only, not its full path: the
/// folder may move (restored backup, export) without rewriting any card.
class ImageStore {
  ImageStore(this.directory);

  /// The store of the app, next to its database.
  static Future<ImageStore> open() async => ImageStore(
    Directory(
      p.join((await getApplicationDocumentsDirectory()).path, 'images'),
    ),
  );

  final Directory directory;
  final Random _random = Random();

  /// Copies the image at [sourcePath] into the store under a new name, and
  /// returns that name.
  Future<String> add(String sourcePath) async {
    await directory.create(recursive: true);
    final suffix = _random.nextInt(1 << 32).toRadixString(16);
    final name =
        '${DateTime.now().microsecondsSinceEpoch}-$suffix'
        '${p.extension(sourcePath).toLowerCase()}';
    await File(sourcePath).copy(pathOf(name));
    return name;
  }

  /// Full path of the image stored under [name].
  String pathOf(String name) => p.join(directory.path, name);

  /// Removes an image; an image already gone is ignored.
  Future<void> delete(String name) async {
    final file = File(pathOf(name));
    if (await file.exists()) {
      await file.delete();
    }
  }
}
