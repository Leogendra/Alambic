import 'dart:io';

import 'package:alambic/data/images/image_store.dart';

/// An image store in a temporary folder, emptied by nothing: each test run
/// gets its own folder.
ImageStore openTestImageStore() =>
    ImageStore(Directory.systemTemp.createTempSync('alambic_images_'));
