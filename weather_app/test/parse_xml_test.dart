import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/location_table.dart';
import 'package:xml/xml.dart' as xml;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test("parsing invalid.xml", () {
    var xmlString = File("test/invalid.xml").readAsStringSync();
    var doc = xml.XmlDocument.parse(xmlString);

    try {
      LocationTable.parseFrom(doc);
      fail("Should throw Argument Error");
    } on ArgumentError {}
  });

  test("parsing primary_area.xml", () async {
    final xmlString = await rootBundle.loadString('assets/primary_area.xml');
    final document = xml.XmlDocument.parse(xmlString);

    var locationTable = LocationTable.parseFrom(document);

    expect(locationTable.prefectures.length, greaterThan(0));
    expect(locationTable.prefectures.first.title, '道北');
    expect(locationTable.prefectures.first.cities.length, 3);
    expect(locationTable.prefectures.first.cities.first.title, '稚内');
    expect(locationTable.prefectures.first.cities.first.id, '011000');

    expect(locationTable.prefectures.last.title, '沖縄県');
    expect(locationTable.prefectures.last.cities.length, 7);
    expect(locationTable.prefectures.last.cities.last.title, '与那国島');
    expect(locationTable.prefectures.last.cities.last.id, '474020');
  });
}
