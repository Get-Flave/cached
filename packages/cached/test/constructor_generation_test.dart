import 'package:path/path.dart' as path;
import 'package:persistant_cached/src/cached_generator.dart';
import 'package:persistant_cached/src/config.dart';
import 'package:source_gen_test/source_gen_test.dart';

Future<void> main() async {
  initializeBuildLogTracking();
  const expectedAnnotatedTests = {
    'PositionalArguments',
    'OptionalArguments',
    'NamedArguments',
    'PositionalAndOptinalArguments',
    'PositionalAndNamesArguments',
  };

  final reader = await initializeLibraryReaderForDirectory(
    path.join('test', 'inputs'),
    'constructor_generation_test_input.dart',
  );

  testAnnotatedElements(
    reader,
    const CachedGenerator(config: Config()),
    expectedAnnotatedTests: expectedAnnotatedTests,
  );
}
