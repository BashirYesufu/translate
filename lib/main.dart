import 'package:flutter/material.dart';
import 'package:simplytranslate/simplytranslate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    final gt = SimplyTranslator(EngineType.google);

    return Scaffold(
      body: Center(
        child: TranslatedText(text: 'Tell me where you are going',),
      ),
    );
  }
}

class TranslatedText extends StatefulWidget {
  const TranslatedText({
    super.key,
    required this.text,
    this.source = 'en',
    this.target,
  });

  final String text;
  final String source;
  final String? target;

  @override
  State<TranslatedText> createState() => _TranslatedTextState();
}

class _TranslatedTextState extends State<TranslatedText> {
  @override
  Widget build(BuildContext context) {
    final gt = SimplyTranslator(EngineType.google);

    return FutureBuilder(
      future: gt.trSimply(widget.text, widget.source, widget.target ?? 'es'),
      builder: (context, snapshot) {
        print(snapshot.data);
        return Text(
          snapshot.data ?? widget.text
        );
      }
    );
  }
}
