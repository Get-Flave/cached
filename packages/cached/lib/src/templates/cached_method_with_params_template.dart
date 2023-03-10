import 'package:collection/collection.dart';
import 'package:persistant_cached/src/models/cached_method.dart';
import 'package:persistant_cached/src/models/param.dart';
import 'package:persistant_cached/src/templates/all_params_template.dart';
import 'package:persistant_cached/src/templates/cached_method_template.dart';
import 'package:persistant_cached/src/utils/utils.dart';

class CachedMethodWithParamsTemplate extends CachedMethodTemplate {
  CachedMethodWithParamsTemplate(
    this.method, {
    required bool useStaticCache,
    required bool isCacheStreamed,
  })  : paramsTemplate = AllParamsTemplate(method.params),
        super(
          method,
          useStaticCache: useStaticCache,
          isCacheStreamed: isCacheStreamed,
        );

  final AllParamsTemplate paramsTemplate;
  final CachedMethod method;

  Param? get ignoreCacheParam => method.params.firstWhereOrNull(
        (element) => element.ignoreCacheAnnotation != null,
      );

  @override
  String get paramsKey => getParamKey(method.params);

  @override
  String generateDefinition() {
    final params = paramsTemplate.generateParams();
    return '${function.name}($params)';
  }

  @override
  String generateUsage() {
    final paramsUsage = paramsTemplate.generateParamsUsage();
    return '${function.name}($paramsUsage)';
  }

  @override
  String generateAdditionalCacheCondition() {
    final ignoreCacheParam = this.ignoreCacheParam;
    if (ignoreCacheParam != null) {
      return '|| ${ignoreCacheParam.name}';
    }

    return '';
  }

  @override
  String generateOnCatch() {
    final ignoreCacheAnnotation = ignoreCacheParam?.ignoreCacheAnnotation;
    final useCacheOnError = ignoreCacheAnnotation?.useCacheOnError;
    final safeUseCacheOnError = useCacheOnError ?? false;
    final text = safeUseCacheOnError
        ? 'if (cachedValue != null) { return cachedValue;\n }'
        : '';

    return '${text}rethrow;';
  }
}
