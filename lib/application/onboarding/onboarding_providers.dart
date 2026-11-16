import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'first_group_controller.dart';

final firstGroupProvider = NotifierProvider<FirstGroupController, int?>(
  FirstGroupController.new,
);
