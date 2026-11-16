import 'package:drift/drift.dart';

import '../../domain/reviews/review_outcome.dart';
import '../../domain/reviews/review_record.dart';
import '../../domain/reviews/review_source.dart';
import '../database/alambic_database.dart';

/// History of answers.
class ReviewRepository {
  const ReviewRepository(this._database);

  final AlambicDatabase _database;

  Future<void> insert({
    required int cardId,
    required DateTime reviewedAt,
    required ReviewOutcome outcome,
    required bool isBonus,
    required int? stepBefore,
    required int? stepAfter,
    required DateTime? dueAtAfter,
    required ReviewSource source,
  }) => _database
      .into(_database.reviewRecords)
      .insert(
        ReviewRecordsCompanion.insert(
          cardId: cardId,
          reviewedAt: reviewedAt,
          outcome: outcome,
          isBonus: isBonus,
          stepBefore: Value(stepBefore),
          stepAfter: Value(stepAfter),
          dueAtAfter: Value(dueAtAfter),
          source: source,
        ),
      );

  /// History of one card, most recent first.
  Stream<List<ReviewRecord>> watchHistory(int cardId) =>
      (_database.select(_database.reviewRecords)
            ..where((review) => review.cardId.equals(cardId))
            ..orderBy([
              (review) => OrderingTerm.desc(review.reviewedAt),
              (review) => OrderingTerm.desc(review.id),
            ]))
          .watch();

  /// Answers given from [start] on, bonus reviews included.
  Stream<List<ReviewRecord>> watchSince(DateTime start) => (_database.select(
    _database.reviewRecords,
  )..where((review) => review.reviewedAt.isBiggerOrEqualValue(start))).watch();
}
