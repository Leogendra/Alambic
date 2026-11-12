import 'package:drift/drift.dart';

import '../../../domain/reviews/review_outcome.dart';
import '../../../domain/reviews/review_record.dart';
import '../../../domain/reviews/review_source.dart';
import 'card_directions.dart';

@UseRowClass(ReviewRecord)
@TableIndex(name: 'review_records_reviewed_at', columns: {#reviewedAt})
class ReviewRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get directionId =>
      integer().references(CardDirections, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get reviewedAt => dateTime()();
  TextColumn get outcome => textEnum<ReviewOutcome>()();
  BoolColumn get isBonus => boolean()();
  IntColumn get stepBefore => integer().nullable()();
  IntColumn get stepAfter => integer().nullable()();
  DateTimeColumn get dueAtAfter => dateTime().nullable()();
  TextColumn get source => textEnum<ReviewSource>()();
}
