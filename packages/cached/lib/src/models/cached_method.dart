import 'package:analyzer/dart/element/element.dart';
import 'package:persistant_cached/src/config.dart';
import 'package:persistant_cached/src/models/cached_function.dart';
import 'package:persistant_cached/src/models/cached_function_local_config.dart';
import 'package:persistant_cached/src/models/param.dart';
import 'package:persistant_cached/src/utils/asserts.dart';

const _defaultSyncWriteValue = false;

class CachedMethod extends CachedFunction {
  CachedMethod._({
    required this.params,
    required super.name,
    required super.syncWrite,
    required super.returnType,
    required super.isGenerator,
    required super.isAsync,
    required super.limit,
    required super.ttl,
    required super.checkIfShouldCacheMethod,
    required super.persistentStorage,
  });

  factory CachedMethod.fromElement(
    MethodElement element,
    Config config,
  ) {
    CachedFunction.assertIsValid(element);

    final localConfig = CachedFunctionLocalConfig.fromElement(element);
    if (localConfig.persistentStorage == true) {
      assertPersistentStorageShouldBeAsync(element);
    }

    final unsafeSyncWrite = localConfig.syncWrite ?? config.syncWrite;
    final syncWrite = unsafeSyncWrite ?? _defaultSyncWriteValue;
    final limit = localConfig.limit ?? config.limit;
    final ttl = localConfig.ttl ?? config.ttl;
    final persistentStorage = localConfig.persistentStorage ?? false;
    final returnType = element.returnType.getDisplayString(
      withNullability: true,
    );
    final params = element.parameters.map(
      (e) => Param.fromElement(e, config),
    );

    final method = CachedMethod._(
      name: element.name,
      syncWrite: syncWrite,
      limit: limit,
      ttl: ttl,
      checkIfShouldCacheMethod: localConfig.checkIfShouldCacheMethod,
      isAsync: element.isAsynchronous,
      isGenerator: element.isGenerator,
      persistentStorage: persistentStorage,
      returnType: returnType,
      params: params,
    );

    assertOneIgnoreCacheParam(method);

    return method;
  }

  final Iterable<Param> params;
}
