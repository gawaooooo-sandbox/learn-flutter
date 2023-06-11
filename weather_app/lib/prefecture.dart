import 'package:weather_app/city.dart';
import 'package:xml/xml.dart';
import 'xml_parsable_base.dart';

// @see https://dev.classmethod.jp/articles/intro_dart_xml/

class Prefecture extends XMLParsableBase {
  final String title;
  final List<City> cities;

  Prefecture._(this.title, this.cities);

  factory Prefecture.parseFrom(XmlElement element) {
    var title = ParseHelper.stringFromAttributeOrNil(element, 'title');
    var cities = element
        .findAllElements('city')
        .map((XmlElement element) => City.parseFrom(element))
        .toList();

    return Prefecture._(title!, cities);
  }
}
