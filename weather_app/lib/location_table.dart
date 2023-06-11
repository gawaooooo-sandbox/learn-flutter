import 'package:weather_app/prefecture.dart';
import 'package:weather_app/xml_parsable_base.dart';
import 'package:xml/xml.dart';

class LocationTable extends XMLParsableBase {
  final List<Prefecture> prefectures;

  LocationTable._(this.prefectures);

  factory LocationTable.parseFrom(XmlDocument document) {
    XmlElement channelElement;
    XmlElement ldWeatherElement;

    try {
      channelElement = document.findAllElements('channel').first;
    } on StateError {
      throw ArgumentError('channel not found');
    }

    try {
      // ldWeather:source
      ldWeatherElement =
          channelElement.findAllElements('ldWeather:source').first;
    } on StateError {
      throw ArgumentError('ldWeather:source not found');
    }

    var prefectures = ldWeatherElement
        .findAllElements('pref')
        .map((XmlElement element) => Prefecture.parseFrom(element))
        .toList();

    return LocationTable._(prefectures);
  }
}
