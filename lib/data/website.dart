import 'package:meta/meta.dart';

class WebsiteSetting {
  String title;
  bool value;
  String id;
  WebsiteSetting({
    @required this.title,
    this.value = false,
    this.id,
  });
}
