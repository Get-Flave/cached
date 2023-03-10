import 'package:analyzer/dart/element/element.dart';
import 'package:persistant_cached/src/config.dart';
import 'package:persistant_cached/src/models/param.dart';

class Constructor {
  const Constructor({
    required this.params,
  });

  factory Constructor.fromElement(ConstructorElement element, Config config) {
    return Constructor(
      params: element.parameters.map((e) => Param.fromElement(e, config)),
    );
  }

  final Iterable<Param> params;
}
