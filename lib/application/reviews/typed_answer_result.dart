import '../../domain/reviews/typed_answer_match.dart';
import 'review_result.dart';

/// A typed answer once compared with the answer face and recorded.
class TypedAnswerResult {
  const TypedAnswerResult({required this.match, required this.result});

  final TypedAnswerMatch match;
  final ReviewResult result;
}
