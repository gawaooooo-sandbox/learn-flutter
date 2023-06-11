import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weather_app/city.dart';
import 'package:weather_app/location_table.dart';
import 'package:weather_app/prefecture.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'color_schemes.g.dart';
import 'load_primary_area.dart';

void main() {
  runApp(const WeatherApp(title: 'Weather App'));
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  Map<String, dynamic>? _weatherData;
  LocationTable? _primaryAreaData;

  Prefecture? _selectedPrefecture;
  City? _selectedCity;

  Future<void> _fetchWeatherData() async {
    final response = await http.get(Uri.parse(
        'https://weather.tsukumijima.net/api/forecast/city/${_selectedCity?.id}'));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final encodedData = utf8.decode(bytes); // UTF-8エンコーディングを指定
      final data = json.decode(encodedData);

      // if (kDebugMode) {
      //   print(data);
      // }

      setState(() {
        _weatherData = data;
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<void> _loadPrimaryAreaData() async {
    loadPrimaryAreaXml().then((value) {
      setState(() {
        _primaryAreaData = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPrimaryAreaData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          // useMaterial3: true,
          colorScheme: lightColorScheme,
          textTheme: GoogleFonts.stickTextTheme(Theme.of(context).textTheme)),
      darkTheme: ThemeData(
          // useMaterial3: true,
          colorScheme: darkColorScheme,
          textTheme: GoogleFonts.stickTextTheme(Theme.of(context).textTheme)),
      home: Builder(builder: (context) {
        return Scaffold(
            appBar: AppBar(
              elevation: 2,
              title: const Text('Weather App for Chiba Residents'),
            ),
            body: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    image: const DecorationImage(
                        opacity: 0.8,
                        image: AssetImage('assets/chiba_splash.png'),
                        fit: BoxFit.cover)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 13.0, sigmaY: 13.0),
                  child: _primaryAreaData == null
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Center(
                          child: Column(
                            // mainAxisSize: MainAxisSize.min,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10.0),
                              Column(
                                children: [
                                  Text(
                                    'ねぇ、',
                                    style: TextStyle(
                                        shadows: [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            blurRadius: 50, //ぼやけ具合
                                          )
                                        ],
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'どこの天気予報見る？',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                              Row(
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.sunny,
                                      size: 36,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceTint,
                                      shadows: const [
                                        BoxShadow(
                                          color: Colors.lightBlueAccent, //色
                                          blurRadius: 45, //ぼやけ具合
                                        )
                                      ],
                                    ),
                                    DropdownButton(
                                        style: GoogleFonts.stick(
                                            fontSize: 28,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer,
                                            height: 0.8),
                                        icon: const Icon(Icons.arrow_drop_down),
                                        iconSize: 35,
                                        underline: Container(
                                          height: 2,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                        alignment: AlignmentDirectional.center,
                                        value: _selectedPrefecture,
                                        items: _primaryAreaData!.prefectures
                                            .map((prefecture) =>
                                                DropdownMenuItem(
                                                  value: prefecture,
                                                  child: Text(prefecture.title),
                                                ))
                                            .toList(),
                                        onChanged: (value) {
                                          // print(value?.title);
                                          setState(() {
                                            _selectedPrefecture = value;
                                            _selectedCity = null;
                                          });
                                        }),
                                    if (_selectedPrefecture != null)
                                      DropdownButton(
                                          style: GoogleFonts.stick(
                                              fontSize: 28,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondaryContainer,
                                              height: 0.8),
                                          icon:
                                              const Icon(Icons.arrow_drop_down),
                                          iconSize: 35,
                                          underline: Container(
                                            height: 2,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                          alignment:
                                              AlignmentDirectional.center,
                                          value: _selectedCity,
                                          items: _primaryAreaData!.prefectures
                                              .firstWhere((prefecture) =>
                                                  prefecture ==
                                                  _selectedPrefecture)
                                              .cities
                                              .map((city) => DropdownMenuItem(
                                                  value: city,
                                                  child: Text(city.title)))
                                              .toList(),
                                          onChanged: (value) {
                                            // print(
                                            //     '${value?.id} : ${value?.title}');
                                            setState(() {
                                              _selectedCity = value;
                                            });
                                          }),
                                    Icon(
                                      Icons.thunderstorm,
                                      size: 36,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      shadows: const [
                                        BoxShadow(
                                          color: Colors.lightBlueAccent, //色
                                          blurRadius: 45, //ぼやけ具合
                                        )
                                      ],
                                    )
                                  ]),
                              const SizedBox(height: 40),
                              if (_selectedPrefecture != null &&
                                  _selectedCity != null)
                                ElevatedButton(
                                  onPressed: () =>
                                      {showWeatherForecast(context)},
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(200, 100),
                                  ),
                                  child: const Text(
                                    'ほんとうに見る？',
                                    style: TextStyle(fontSize: 30),
                                  ),
                                ),
                            ],
                          ),
                        ),
                )));
      }),
    );
  }

  void showWeatherForecast(context) {
    if (_selectedPrefecture?.title == '千葉県') {
      _fetchWeatherData();
    } else {
      _weatherData = null;
    }

    var now = DateTime.now();
    // print(now.hour);
    var timeFormat = DateFormat('yyyy/MM/dd HH:mm:ss');
    var currentTime = timeFormat.format(now);
    // print(currentTime);

    String currentTimeChanceOfRain(chanceOfRain) {
      if (chanceOfRain == null) {
        return '---';
      }

      if (now.hour >= 0 && now.hour < 6) {
        return chanceOfRain['T00_06'];
      }
      if (now.hour >= 6 && now.hour < 12) {
        return chanceOfRain['T06_12'];
      }
      if (now.hour >= 12 && now.hour < 18) {
        return chanceOfRain['T12_18'];
      }
      return chanceOfRain['T18_24'];
    }

    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
            margin: const EdgeInsets.only(top: 100),
            color: Theme.of(context).colorScheme.errorContainer,
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_weatherData == null)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ちがうよね？',
                            style: TextStyle(
                                // color: Colors.pinkAccent,
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                          Icon(
                            Icons.sentiment_dissatisfied,
                            size: 36,
                            color: Theme.of(context).colorScheme.surfaceTint,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'よく考えて？',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 40,
                                fontWeight: FontWeight.bold),
                          ),
                          Icon(
                            Icons.mood_bad,
                            size: 40,
                            color: Theme.of(context).colorScheme.surfaceTint,
                          ),
                        ],
                      ),
                    ],
                  ),
                if (_weatherData != null)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.today,
                              size: 32,
                              color: Theme.of(context).colorScheme.surfaceTint,
                            ),
                            Text(
                              currentTime,
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              '${_weatherData!['publicTimeFormatted']} 発表',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              _weatherData!['title'],
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Table(
                          border: TableBorder(
                              horizontalInside: BorderSide(
                                  width: 1.5,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                  style: BorderStyle.solid)),
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          columnWidths: const {
                            0: FlexColumnWidth(0.5),
                            1: FlexColumnWidth(1.5),
                            2: FlexColumnWidth(0.5),
                            3: FlexColumnWidth(0.5),
                            4: FlexColumnWidth(0.5),
                          },
                          children: [
                            for (var forecast in _weatherData!['forecasts'])
                              TableRow(
                                children: [
                                  TableCell(
                                      child: Text(forecast['dateLabel'] ?? '')),
                                  TableCell(
                                      child: Row(
                                    children: [
                                      if (forecast['image']['url'] != '')
                                        SvgPicture.network(
                                            forecast['image']['url']),
                                      Text(forecast['telop'] ?? ''),
                                    ],
                                  )),
                                  TableCell(
                                      child: Text(currentTimeChanceOfRain(
                                          forecast['chanceOfRain']))),
                                  TableCell(
                                      child: Row(
                                    children: [
                                      Text(
                                        forecast['temperature']['min']
                                                ['celsius'] ??
                                            '',
                                        style:
                                            const TextStyle(color: Colors.blue),
                                      ),
                                      Text(
                                          forecast['temperature']['min']
                                                      ['celsius'] !=
                                                  null
                                              ? '℃'
                                              : '',
                                          style: const TextStyle(
                                              color: Colors.blue, fontSize: 10))
                                    ],
                                  )),
                                  TableCell(
                                      child: Row(
                                    children: [
                                      Text(
                                        forecast['temperature']['max']
                                                ['celsius'] ??
                                            '',
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
                                      Text(
                                          forecast['temperature']['max']
                                                      ['celsius'] !=
                                                  null
                                              ? '℃'
                                              : '',
                                          style: const TextStyle(
                                              color: Colors.red, fontSize: 10))
                                    ],
                                  )),
                                ],
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          child: Text(
                            _weatherData!['description']['bodyText'],
                          ),
                        ),
                      ),
                    ],
                  ),
                ElevatedButton(
                  child: const Text('Close'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            )),
          );
        });
  }
}
