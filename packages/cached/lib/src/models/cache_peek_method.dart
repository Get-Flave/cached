import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:cached_annotation/cached_annotation.dart';
import 'package:collection/collection.dart';
import 'package:persistant_cached/src/config.dart';
import 'package:persistant_cached/src/models/param.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

class CachePeekMethod {
  const CachePeekMethod({
    required this.name,
    required this.targetMethodName,
    required this.returnType,
    required this.params,
  });

  factory CachePeekMethod.fromElement(
    MethodElement element,
    List<ExecutableElement> classMethods,
    Config config,
  ) {
    final annotation = getAnnotation(element);

    var methodName = '';

    if (annotation != null) {
      final reader = ConstantReader(annotation);
      methodName = reader.read('methodName').stringValue;
    }

    final targetMethod = classMethods
        .where(
          (m) => m.name == methodName,
        )
        .firstOrNull;

    if (targetMethod == null) {
      throw InvalidGenerationSourceError(
        '[ERROR] Method "$methodName" do not exists',
        element: element,
      );
    }

    final peekCacheMethodType = element.returnType;
    final peekCacheMethodTypeStr = peekCacheMethodType.getDisplayString(
      withNullability: false,
    );

    const futureTypeChecker = TypeChecker.fromRuntime(Future);
    final targetMethodReturnType = targetMethod.returnType.isDartAsyncFuture
        ? targetMethod.returnType.typeArgumentsOf(futureTypeChecker)?.single
        : targetMethod.returnType;

    final targetMethodTypeStr = targetMethodReturnType?.getDisplayString(
      withNullability: false,
    );

    if (peekCacheMethodTypeStr != targetMethodTypeStr) {
      throw InvalidGenerationSourceError(
        '[ERROR] Peek cache method return type needs to be a $targetMethodTypeStr?',
        element: element,
      );
    }

    const cachedAnnotationTypeChecker = TypeChecker.fromRuntime(Cached);

    if (!cachedAnnotationTypeChecker.hasAnnotationOf(targetMethod)) {
      throw InvalidGenerationSourceError(
        '[ERROR] Method "$methodName" do not have @cached annotation',
        element: element,
      );
    }

    const ignoreTypeChecker = TypeChecker.any([
      TypeChecker.fromRuntime(Ignore),
      TypeChecker.fromRuntime(IgnoreCache),
    ]);

    final targetMethodParameters = targetMethod.parameters
        .where((p) => !ignoreTypeChecker.hasAnnotationOf(p))
        .toList();

    if (!ListEquality<ParameterElement>(
      EqualityBy(
        (p) => Param.fromElement(p, config),
      ),
    ).equals(
      targetMethodParameters,
      element.parameters,
    )) {
      throw InvalidGenerationSourceError(
        '[ERROR] Method "${targetMethod.name}" should have same parameters as "${element.name}", excluding ones marked with @ignore and @ignoreCache',
        element: element,
      );
    }

    return CachePeekMethod(
      name: element.name,
      returnType: peekCacheMethodTypeStr,
      params: targetMethodParameters.map((p) => Param.fromElement(p, config)),
      targetMethodName: methodName,
    );
  }

  final String name;
  final String targetMethodName;
  final Iterable<Param> params;
  final String returnType;

  static DartObject? getAnnotation(MethodElement element) {
    const methodAnnotationChecker = TypeChecker.fromRuntime(CachePeek);
    return methodAnnotationChecker.firstAnnotationOf(element);
  }
}
