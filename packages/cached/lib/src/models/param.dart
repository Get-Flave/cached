import 'package:analyzer/dart/element/element.dart';
import 'package:cached/src/config.dart';
import 'package:cached_annotation/cached_annotation.dart';
import 'package:source_gen/source_gen.dart';

const _defaultOnCacheOnError = false;

class IgnoreCacheAnnotation {
  const IgnoreCacheAnnotation({
    required this.useCacheOnError,
  });

  final bool useCacheOnError;
}

class CacheKeyAnnotation {
  const CacheKeyAnnotation({
    required this.cacheFunctionCall,
  });

  final String cacheFunctionCall;
}

class Param {
  const Param({
    required this.name,
    required this.type,
    required this.isNamed,
    required this.isOptional,
    this.ignoreCacheAnnotation,
    this.cacheKeyAnnotation,
    this.defaultValue,
  });

  final String name;
  final String type;
  final bool isNamed;
  final bool isOptional;
  final String? defaultValue;
  final IgnoreCacheAnnotation? ignoreCacheAnnotation;
  final CacheKeyAnnotation? cacheKeyAnnotation;

  factory Param.fromElement(ParameterElement element, Config config) {
    const paramAnnotationChecker = TypeChecker.fromRuntime(IgnoreCache);
    const cacheKeyAnnotationChecker = TypeChecker.fromRuntime(CacheKey);

    final annotation = paramAnnotationChecker.firstAnnotationOf(element);
    final cacheKeyAnnotation =
        cacheKeyAnnotationChecker.firstAnnotationOf(element);

    IgnoreCacheAnnotation? annotationData;
    CacheKeyAnnotation? cacheKeyAnnotationData;

    if (annotation != null && cacheKeyAnnotation != null) {
      throw InvalidGenerationSourceError(
        '[ERROR] Ignore cache cannot be used with cache key annotation',
        element: element,
      );
    }

    if (annotation != null) {
      if (element.type.getDisplayString(withNullability: true) != 'bool') {
        throw InvalidGenerationSourceError(
          '[ERROR] Ignore cache param need to be not nullable bool',
          element: element,
        );
      }
      annotationData = IgnoreCacheAnnotation(
        useCacheOnError: config.onCacheOnError ?? _defaultOnCacheOnError,
      );

      final reader = ConstantReader(annotation);
      final useCacheOnErrorField = reader.read('useCacheOnError');
      if (useCacheOnErrorField.isBool) {
        annotationData = IgnoreCacheAnnotation(
          useCacheOnError: useCacheOnErrorField.boolValue,
        );
      }
    }

    if (cacheKeyAnnotation != null) {
      final reader = ConstantReader(cacheKeyAnnotation);
      final cacheKeyFuncReader = reader.read('cacheKeyGenerator');
      final cacheKeyFunc = cacheKeyFuncReader.objectValue.toFunctionValue();
      if (cacheKeyFunc != null) {
        if (cacheKeyFunc.librarySource.fullName
                .startsWith('/cached_annotation/') &&
            cacheKeyFunc.name == 'iterableCacheKeyGenerator' &&
            !element.type.isDartCoreList) {
          throw InvalidGenerationSourceError(
            '[ERROR] Iterable cache key generator requires iterable parameter',
            element: element,
          );
        }

        cacheKeyAnnotationData = CacheKeyAnnotation(
          cacheFunctionCall: cacheKeyFunc.name,
        );
      }
    }

    return Param(
      name: element.name,
      type: element.type.getDisplayString(withNullability: true),
      ignoreCacheAnnotation: annotationData,
      defaultValue: element.defaultValueCode,
      isNamed: element.isNamed,
      isOptional: element.isOptional,
      cacheKeyAnnotation: cacheKeyAnnotationData,
    );
  }

  bool get isPositional => !isNamed;

  bool get isRequired => !isOptional;

  bool get isRequiredPositional => isRequired && isPositional;

  bool get isOptionalPositional => isOptional && isPositional;

  bool get isRequiredNamed => isRequired && isNamed;

  bool get isOptionalNamed => isOptional && isNamed;

  String get typeWithName => '$type $name';
}
