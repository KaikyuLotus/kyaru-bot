import '../../kyaru.dart';

abstract class IModule {
  bool isEnabled();

  List<ModuleFunction>? get moduleFunctions;
}
