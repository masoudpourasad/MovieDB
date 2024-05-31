import 'package:flutter/material.dart';
import 'package:moviedb/api/endpoints.dart';
import 'package:moviedb/modal_class/function.dart';
import 'package:moviedb/modal_class/genres.dart';
import 'package:moviedb/modal_class/movie.dart';
import 'package:moviedb/screens/movie_detail.dart';
import 'package:moviedb/screens/search_view.dart';
import 'package:moviedb/screens/settings.dart';
import 'package:moviedb/screens/widgets.dart';
import 'package:moviedb/theme/theme_state.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeState>(
      create: (_) => ThemeState(),
      child: MaterialApp(
        title: 'Movie Db',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.blue, canvasColor: Colors.transparent),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Genres> _genres = [];
  @override
  void initState() {
    super.initState();
    fetchGenres().then((value) {
      _genres = value.genres ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ThemeState>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: state.themeData.primaryIconTheme.color,
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        centerTitle: true,
        title: Text(
          'Movie DB',
          style: state.themeData.textTheme.headlineSmall,
        ),
        backgroundColor: state.themeData.primaryColor,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final Movie? result = await showSearch<Movie?>(
                  context: context,
                  delegate:
                      MovieSearch(themeData: state.themeData, genres: _genres));
              if (result != null) {
                setState(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MovieDetailPage(
                              movie: result,
                              themeData: state.themeData,
                              genres: _genres,
                              heroId: '${result.id}search')));
                });
              }
            },
          )
        ],
      ),
      drawer: const Drawer(
        child: SettingsPage(),
      ),
      body: Container(
        color: state.themeData.primaryColor,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            DiscoverMovies(
              themeData: state.themeData,
              genres: _genres,
            ),
            ScrollingMovies(
              themeData: state.themeData,
              title: 'Top Rated',
              api: Endpoints.topRatedUrl(1),
              genres: _genres,
            ),
            ScrollingMovies(
              themeData: state.themeData,
              title: 'Now Playing',
              api: Endpoints.nowPlayingMoviesUrl(1),
              genres: _genres,
            ),
            ScrollingMovies(
              themeData: state.themeData,
              title: 'Upcoming Movies',
              api: Endpoints.upcomingMoviesUrl(1),
              genres: _genres,
            ),
            ScrollingMovies(
              themeData: state.themeData,
              title: 'Popular',
              api: Endpoints.popularMoviesUrl(1),
              genres: _genres,
            ),
          ],
        ),
      ),
    );
  }
}
