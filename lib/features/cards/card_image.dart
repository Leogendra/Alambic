import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/alambic_colors.dart';
import '../../application/cards/draft_image.dart';
import '../../data/data_providers.dart';

/// The image of a card face, from the image store or just picked.
class CardImage extends ConsumerWidget {
  const CardImage(
    this.image, {
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.radius = 12,
    super.key,
  });

  /// The image stored under [name].
  CardImage.stored(
    String name, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    double radius = 12,
    Key? key,
  }) : this(
         StoredImage(name),
         width: width,
         height: height,
         fit: fit,
         radius: radius,
         key: key,
       );

  final DraftImage image;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = switch (image) {
      StoredImage(:final name) => ref.watch(imageStoreProvider).pathOf(name),
      PickedImage(:final path) => path,
    };
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.file(
        File(path),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => SizedBox(
          width: width,
          height: height,
          child: Icon(
            Icons.broken_image_outlined,
            color: AlambicColors.of(context).textTertiary,
          ),
        ),
      ),
    );
  }
}
