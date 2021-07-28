import 'package:meta/meta.dart';

class CategorySetting {
  String title;
  bool value;
  String id;
  CategorySetting({
    @required this.title,
    this.value = false,
    this.id,
  });
}
