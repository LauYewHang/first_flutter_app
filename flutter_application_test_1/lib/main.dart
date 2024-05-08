import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

/*
  The MyApp class extends StatelessWidget. 
  Widgets are the elements from which you build every Flutter app. 
  As you can see, even the app itself is a widget
*/
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          // Flutter's Colors class gives you convenient access to a palette of hand-picked colors, 
          // such as Colors.deepOrange or Colors.red. 
          // But you can, of course, choose any color. To define pure green with full opacity, for example, 
          // use Color.fromRGBO(0, 255, 0, 1.0). If you're a fan of hexadecimal numbers, there's always Color(0xFF00FF00).
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(51, 0, 102, 0.7)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

/*
  ChangeNotifier:
  1.  MyAppState defines the data the app needs to function. 
      Right now, it only contains a single variable with the current random word pair.
  2.  The state class extends ChangeNotifier, which means that it can notify others about its own changes. 
      For example, if the current word pair changes, some widgets in the app need to know.
  3.  The state is created and provided to the whole app using a ChangeNotifierProvider.
      This allows any widget in the app to get hold of the state. 
*/
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext(){
    // The new getNext() method reassigns current with a new random WordPair.
    current = WordPair.random();
    // It also calls notifyListeners()(a method of ChangeNotifier)that ensures that anyone watching MyAppState is notified.
    notifyListeners();
  }

  var favourites = <WordPair>[];

  void toggleFavourite(){
    if (favourites.contains(current)){
      favourites.remove(current);
    }else{
      favourites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    Widget page;
      switch (selectedIndex) {
        case 0:
          page = GeneratorPage();
          break;
        case 1:
          page = FavoritesPage();
          break;
        default:
          throw UnimplementedError('no widget for $selectedIndex');
      }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              // The SafeArea ensures that its child is not obscured by a hardware notch or a status bar. 
              // In this app, the widget wraps around NavigationRail to prevent the navigation buttons from being obscured by a mobile status bar, for example.
              SafeArea(
                child: NavigationRail(
                  // You can change the extended: false line in NavigationRail to true.
                  // This shows the labels next to the icons.
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favourites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              // Expanded let you express layouts where some children take only as much space as they need,
              // and other widgets should take as much of the remaining room as possible.
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}


class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favourites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavourite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favourites.isEmpty) {
      return Center(
        child: Text('No favourites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favourites.length} favourites:'),
        ),
        for (var pair in appState.favourites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}


class caption extends StatelessWidget {
  const caption({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text('A random AWESOME idea', style: TextStyle(fontStyle: FontStyle.italic));
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    // the code requests the app's current theme with Theme.of(context)
    final theme = Theme.of(context);
    // By using theme.textTheme, you access the app's font theme. 
    // This class includes members such as bodyMedium (for standard text of medium size), 
    // caption (for captions of images), or 
    // headlineLarge (for large headlines).
    // The displayMedium property is a large style meant for display text. 
    // The word display is used in the typographic sense here, such as in https://en.wikipedia.org/wiki/Display_typeface. 
    // The documentation for displayMedium says that "display styles are reserved for short, important text"—exactly our use case.
    // The theme's displayMedium property could theoretically be null. Dart, the programming language in which you're writing this app, is null-safe, 
    // so it won't let you call methods of objects that are potentially null. 
    // In this case, though, you can use the ! operator ("bang operator") to assure Dart you know what you're doing. 
    // (displayMedium is definitely not null in this case. The reason we know this is beyond the scope of this codelab, though.)
    // Calling copyWith() on displayMedium returns a copy of the text style with the changes you define. 
    // In this case, you're only changing the text's color.
    // copyWith() lets you change a lot more about the text style than just the color. 
    // To get the full list of properties you can change, put your cursor anywhere inside copyWith()'s parentheses, 
    // and hit Ctrl+Shift+Space (Win/Linux) or Cmd+Shift+Space (Mac).

    final style = theme.textTheme.displayMedium!.copyWith(
      // Try experimenting with colors. Apart from theme.colorScheme.primary, there's also .secondary, 
      // .surface, and a myriad of others. All of these colors have their onPrimary equivalents.
      color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
    );

    return Card(
      // The code defines the card's color to be the same as the theme's colorScheme property. 
      // The color scheme contains many colors, and primary is the most prominent, defining color of the app.
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Text(
            pair.asLowerCase, 
            style: style,
            semanticsLabel: "${pair.first} ${pair.second}",
          ),
      ),
    );
  }
}
