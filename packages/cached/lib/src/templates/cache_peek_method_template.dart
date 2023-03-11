import 'package:persistant_cached/src/models/cache_peek_method.dart';
import 'package:persistant_cached/src/templates/all_params_template.dart';
import 'package:persistant_cached/src/utils/utils.dart';

class CachePeekMethodTemplate {
  CachePeekMethodTemplate(
    this.method, {
    required this.className,
  }) : paramsTemplate = AllParamsTemplate(method.params);

  final CachePeekMethod method;
  final String className;
  final AllParamsTemplate paramsTemplate;

  String generateMethod() {
    final params = paramsTemplate.generateParams();
    final paramKey = getParamKey(method.params);
    final cacheMapName = getCacheMapName(method.targetMethodName);

    return '''
      @override
      ${method.returnType}? ${method.name}($params)  {
        final paramsKey = "$paramKey";

        return $cacheMapName[paramsKey];
    }
    ''';
  }
}
