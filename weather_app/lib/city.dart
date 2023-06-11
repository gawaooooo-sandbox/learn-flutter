import 'package:xml/xml.dart';
import 'xml_parsable_base.dart';

// @see https://dev.classmethod.jp/articles/intro_dart_xml/

class City extends XMLParsableBase {
  final String title;
  final String id;

  City._(this.title, this.id);

  factory City.parseFrom(XmlElement element) {
    var title = ParseHelper.stringFromAttributeOrNil(element, 'title');
    var id = ParseHelper.stringFromAttributeOrNil(element, 'id');

    return City._(title!, id!);
  }
}
