import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:weather_app/location_table.dart';
import 'package:xml/xml.dart' as xml;

Future<LocationTable> loadPrimaryAreaXml() async {
  String primaryAreaXml = 'assets/primary_area.xml';
  final primaryArea = await rootBundle.loadString(primaryAreaXml);
  final document = xml.XmlDocument.parse(primaryArea);
  var locationTable = LocationTable.parseFrom(document);

  if (kDebugMode) {
    print(locationTable.prefectures.length);
  }

  return locationTable;
}
