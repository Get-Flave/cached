import 'package:persistant_cached/src/models/cached_getter.dart';
import 'package:persistant_cached/src/templates/cached_method_template.dart';

class CachedGetterTemplate extends CachedMethodTemplate {
  CachedGetterTemplate(
    CachedGetter super.getter, {
    required super.useStaticCache,
    required super.isCacheStreamed,
  });

  @override
  String get paramsKey => '';

  @override
  String generateDefinition() {
    return 'get ${function.name}';
  }

  @override
  String generateUsage() {
    return function.name;
  }

  @override
  String generateOnCatch() {
    return 'rethrow;';
  }
}
