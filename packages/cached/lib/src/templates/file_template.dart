import 'package:persistant_cached/src/models/class_with_cache.dart';
import 'package:persistant_cached/src/templates/class_template.dart';
import 'package:persistant_cached/src/templates/interface_template.dart';

class FileTemplate {
  FileTemplate(ClassWithCache classWithCache)
      : mixinTemplate = InterfaceTemplate(classWithCache),
        classTemplate = ClassTemplate(classWithCache);

  final InterfaceTemplate mixinTemplate;
  final ClassTemplate classTemplate;

  String generate() {
    return '''
       ${mixinTemplate.generate()}

       ${classTemplate.generate()}
    ''';
  }
}
