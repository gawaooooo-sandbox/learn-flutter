import 'package:xml/xml.dart';

// @see https://dev.classmethod.jp/articles/intro_dart_xml/

abstract class XMLParsableBase {}

extension ParseHelper on XMLParsableBase {
  static String stringFrom(XmlElement element, String name) {
    try {
      return element.findElements(name).first.text;
    } on StateError {
      throw ArgumentError("$name not found");
    }
  }

  static String? stringFromOrNil(XmlElement element, String name) {
    try {
      return element.findElements(name).first.text;
    } catch (_) {
      return null;
    }
  }

  static String? stringFromAttributeOrNil(
      XmlElement element, String attribute) {
    try {
      return element.getAttribute(attribute);
    } catch (_) {
      return null;
    }
  }
}
