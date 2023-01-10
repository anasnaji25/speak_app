import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spaek Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Speak Demo'),
    );
  }
}

enum TtsState { playing, stopped, paused, continued }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;



  TextEditingController textEditingController = TextEditingController();

  String? _newVoiceText;
  int? _inputLength;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;
  List<String> list = <String>['English', 'Tamil', 'Malayalam', 'Hindi'];
  late String dropdownValue;
  int _counter = 0;


String speakLang = "Received";
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  initState() {
    super.initState();
    dropdownValue = list.first;
    setState(() {
      speakLang = "Received";
    });
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    _getDefaultEngine();
    _getDefaultVoice();

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future<dynamic> _getLanguages() => flutterTts.getLanguages;

  Future<dynamic> _getEngines() => flutterTts.getEngines;

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  void changedLanguageDropDownItem(String? selectedType) async {
    language = selectedType;
    await flutterTts.setLanguage(selectedType!);
    await flutterTts.isLanguageInstalled(selectedType);

    // flutterTts
    //     .isLanguageInstalled(language!)
    //     .then((value) => isCurrentLanguageInstalled = (value as bool));

    setState(() {});
  }

  Future _speak(text) async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    await flutterTts.speak(text);
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Container(
                height: 50,
                child: TextField(
                    controller: textEditingController,
                    decoration: InputDecoration(
                      labelText: "Enter an amount",
                      enabledBorder: myinputborder(),
                      focusedBorder: myfocusborder(),
                    )),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            DropdownButton<String>(
              value: dropdownValue,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String? value) {
                // This is called when the user selects an item.
                setState(() {
                  dropdownValue = value!;
                });

                if (dropdownValue == "English") {
                  changedLanguageDropDownItem("en-us");
                } else if (dropdownValue == "Tamil") {
                  changedLanguageDropDownItem("ta-IN");
                  setState(() {
                    speakLang = "பெற்றது";
                  });
                } else if (dropdownValue == "Malayalam") {
                  changedLanguageDropDownItem("ml-IN");
                   setState(() {
                    speakLang = "ലഭിച്ചു";
                  });
                } else if (dropdownValue == "Hindi") {
                  changedLanguageDropDownItem("hi-IN");
                    setState(() {
                    speakLang = "प्राप्त किया";
                  });
                }
              },
              items: list.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (textEditingController.text.isNotEmpty) {
  String ruppee = textEditingController.text;
  _speak("$ruppee rupee $speakLang");
    }else{
  _speak("Enter an Amount to Continue");
    }
        },
        tooltip: 'Speak',
        child: const Icon(Icons.volume_up),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  OutlineInputBorder myinputborder() {
    //return type is OutlineInputBorder
    return const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(
          color: Colors.grey,
          width: 1,
        ));
}

  OutlineInputBorder myfocusborder() {
    return const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(
          color: Colors.grey,
          width: 1,
        ));
}
}
