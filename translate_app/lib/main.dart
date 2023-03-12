import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Translate App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _result;
  bool _isLoading = false;

  Future<void> _translate(String sentence) async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('https://jsonplaceholder.typicode.com/posts');
    final headers = {'Content-type': 'application/json; charset=UTF-8'};

    final rand = new math.Random();
    final body = json.encode(
        // {'app_id': '<token>', 'sentence': sentence, 'output_type': 'hiragana'});
        {'title': rand.nextInt(10), 'body': sentence, 'userid': 1});

    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseJson = json.decode(response.body) as Map<String, dynamic>;
      debugPrint('$responseJson');

      setState(() {
        _result = responseJson['body'];
        _isLoading = false;
      });
    } catch (e) {
      // ignore: todo
      // TODO: error
      debugPrint('error!');
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: const Text("Translate App")),
      // 子Widgetを垂直に配置するWidget
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final result = _result;
    if (result != null) {
      return _Result(
          sentence: result,
          onTapBack: () {
            setState(() {
              _result = null;
            });
          });
    } else if (_isLoading) {
      return const _Loading();
    } else {
      return _InputForm(onSubmit: _translate);
    }
  }
  // @override
  // void dispose() {
  //   _textEditController.dispose();
  //   super.dispose();
  // }
}

class _InputForm extends StatefulWidget {
  const _InputForm({super.key, required this.onSubmit});

  final Function(String) onSubmit;
  @override
  State<StatefulWidget> createState() => _InputFormState();
}

class _InputFormState extends State<_InputForm> {
  final _formKey = GlobalKey<FormState>();
  final _textEditController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          // 子Widgetを中央へ寄せるためのパラメータ
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 余白を与えて子要素を配置するWidget
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                    controller: _textEditController,
                    maxLength: 5,
                    decoration: const InputDecoration(hintText: '文章を入力してください'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '文章が入力されていません';
                      }
                      return null;
                    })),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  final formState = _formKey.currentState!;
                  if (!formState.validate()) {
                    return;
                  }
                  widget.onSubmit(_textEditController.text);
                  debugPrint('text = ${_textEditController.text}');
                },
                child: const Text('変換'))
          ],
        ));
  }
}

class _Loading extends StatelessWidget {
  const _Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      // 回転アニメーションする円形のインジケータwidget
      child: CircularProgressIndicator(),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({super.key, required this.sentence, required this.onTapBack});

  final String sentence;
  final void Function() onTapBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(sentence)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: onTapBack, child: const Text('再入力'))
        ],
      ),
    );
  }
}
