/// The image of a face in the card editor.
sealed class DraftImage {
  const DraftImage();
}

/// Already in the image store, under [name].
final class StoredImage extends DraftImage {
  const StoredImage(this.name);

  final String name;
}

/// Just chosen, at [path] outside the store; copied into it on save.
final class PickedImage extends DraftImage {
  const PickedImage(this.path);

  final String path;
}
