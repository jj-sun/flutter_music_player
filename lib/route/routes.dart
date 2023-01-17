import 'package:flutter_music_player/pages/home_page.dart';
import 'package:flutter_music_player/pages/play_list.dart';
import 'package:go_router/go_router.dart';

var goRouter = GoRouter(
    initialLocation: "/",
    routes: [
      GoRoute(
        name: 'home',
        path: '/',
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            name: 'playList',
            path: 'playList',
            builder: (context, state) => PlayList(state.extra),
          )
        ]
      )
    ]
);

/*final routes = {
  '/': (context, { arguments }) => const HomePage(),
  '/playList': (context, { arguments }) => PlayList(arguments: arguments)
};

var onGenerateRoute = (RouteSettings settings) {
  final String? name = settings.name;
  final Function pageContentBuilder = routes[name] as Function;

  if(pageContentBuilder != null) {
    if(settings.arguments != null) {
      final Route route = MaterialPageRoute(
          builder: (context) => pageContentBuilder(context, arguments: settings.arguments)
      );
      return route;
    } else {
      final Route route = MaterialPageRoute(
          builder: (context) => pageContentBuilder(context)
      );
      return route;
    }
  }
};*/
