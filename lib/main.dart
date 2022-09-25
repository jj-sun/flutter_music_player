import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_music_player/common/state/music_play_state.dart';
import 'package:flutter_music_player/route/routes.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<MusicPlayState>(create: (_) => MusicPlayState())
        ],
      child: Consumer(
        builder: (context, state, widget) {
          return MaterialApp(
            initialRoute: '/',
            onGenerateRoute: onGenerateRoute,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            supportedLocales: [
              Locale('zh', 'CH'),
              Locale('en', 'US')
            ],
          );
        },
      ),
    );
  }
}
