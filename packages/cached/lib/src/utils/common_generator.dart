import 'package:persistant_cached/src/utils/persistent_storage_holder_texts.dart';
import 'package:source_gen/source_gen.dart';

class CommonGenerator {
  static const awaitCompleterFutureText = '_completerFuture;';
  static const completerCompleteText = '_completer.complete();';

  static String generatePersistentStorageAwait({
    required bool isPersisted,
    required bool isAsync,
    required String name,
  }) {
    if (!isPersisted) {
      return '';
    }

    if (!isAsync) {
      final message = '[ERROR] All of Cached Persistent Storage methods '
          'have to be async. Source: $name';
      throw InvalidGenerationSourceError(message);
    }

    return '''
       if ($isStorageSetText) {
          $awaitCompleterFutureText 
       }
    ''';
  }
}
