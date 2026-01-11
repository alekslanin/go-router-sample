import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_demo/isolate_sample.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http; 

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

// This scenario demonstrates how to set up nested navigation using ShellRoute,
// which is a pattern where an additional Navigator is placed in the widget tree
// to be used instead of the root navigator. This allows deep-links to display
// pages along with other UI components such as a BottomNavigationBar.
//
// This example demonstrates how use topRoute in a ShellRoute to create the
// title in the AppBar above the child, which is different for each GoRoute.

void main() {
  runApp(ShellRouteExampleApp());
}

/// An example demonstrating how to use [ShellRoute]
class ShellRouteExampleApp extends StatelessWidget {
  /// Creates a [ShellRouteExampleApp]
  ShellRouteExampleApp({super.key});

  final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/a',
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      /// Application shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (BuildContext context, GoRouterState state, Widget child) {
          final String? routeName = GoRouterState.of(context).topRoute?.name;
          // This title could also be created using a route's path parameters in GoRouterState
          final String title = switch (routeName) {
            'a' => 'A Screen',
            'a.details' => 'A Details',
            'b' => 'B Screen',
            'b.details' => 'B Details',
            'c' => 'C Screen',
            'c.details' => 'C Details',
            'd' => 'D Screen',
            'd.details' => 'D Details',            
            _ => 'Unknown',
          };
          return ScaffoldWithNavBar(title: title, child: child);
        },
        routes: <RouteBase>[
          /// The first screen to display in the bottom navigation bar.
          GoRoute(
            // The name of this route used to determine the title in the ShellRoute.
            name: 'a',
            path: '/a',
            builder: (BuildContext context, GoRouterState state) {
              return const ScreenA();
            },
            routes: <RouteBase>[
              // The details screen to display stacked on the inner Navigator.
              // This will cover screen A but not the application shell.
              GoRoute(
                // The name of this route used to determine the title in the ShellRoute.
                name: 'a.details',
                path: 'details',
                builder: (BuildContext context, GoRouterState state) {
                  return const DetailsScreen(label: 'A');
                },
              ),
            ],
          ),

          /// Displayed when the second item in the the bottom navigation bar is
          /// selected.
          GoRoute(
            // The name of this route used to determine the title in the ShellRoute.
            name: 'b',
            path: '/b',
            builder: (BuildContext context, GoRouterState state) {
              return const ScreenB();
            },
            routes: <RouteBase>[
              // The details screen to display stacked on the inner Navigator.
              // This will cover screen B but not the application shell.
              GoRoute(
                // The name of this route used to determine the title in the ShellRoute.
                name: 'b.details',
                path: 'details',
                builder: (BuildContext context, GoRouterState state) {
                  return const DetailsScreen(label: 'B');
                },
              ),
            ],
          ),

          /// The third screen to display in the bottom navigation bar.
          GoRoute(
            // The name of this route used to determine the title in the ShellRoute.
            name: 'c',
            path: '/c',
            builder: (BuildContext context, GoRouterState state) {
              return const ScreenC();
            },
            routes: <RouteBase>[
              // The details screen to display stacked on the inner Navigator.
              // This will cover screen C but not the application shell.
              GoRoute(
                // The name of this route used to determine the title in the ShellRoute.
                name: 'c.details',
                path: 'details',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (BuildContext context, GoRouterState state) {
                  return MyHomePage(title: "isolate sample");
                },
              ),
            ],
          ),

          GoRoute(
            // The name of this route used to determine the title in the ShellRoute.
            name: 'd',
            path: '/d',
            builder: (BuildContext context, GoRouterState state) {
              return const ScreenD();
            },
            routes: <RouteBase>[
              // The details screen to display stacked on the inner Navigator.
              // This will cover screen C but not the application shell.
              GoRoute(
                // The name of this route used to determine the title in the ShellRoute.
                name: 'd.details',
                path: 'details',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (BuildContext context, GoRouterState state) {
                  return AutoApiCallScreen();
                },
              ),
            ],
          ),


          GoRoute(
            path: '/o',
            builder: (BuildContext context, GoRouterState state) {
                  return ErrorScreen(label: 'cannot be called from this route');
            },
            routes: <RouteBase>[
              // The details screen to display stacked on the inner Navigator.
              // This will cover screen C but not the application shell.
              GoRoute(
                // The name of this route used to determine the title in the ShellRoute.
                name: 'menu',
                path: 'menu',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (BuildContext context, GoRouterState state) {
                  return Menu();
                },
              ),
            ],
          ),

          
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: _router,
    );
  }
}

/// Builds the "shell" for the app by building a Scaffold with a
/// BottomNavigationBar, where [child] is placed in the body of the Scaffold.
class ScaffoldWithNavBar extends StatelessWidget {
  /// Constructs an [ScaffoldWithNavBar].
  const ScaffoldWithNavBar({
    super.key,
    required this.title,
    required this.child,
  });

  /// The title to display in the AppBar.
  final String title;

  /// The widget to display in the body of the Scaffold.
  /// In this sample, it is a Navigator.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      appBar: AppBar(title: Text(title), leading: _buildLeadingButton(context)),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'A Screen'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'B Screen',),
          BottomNavigationBarItem(icon: Icon(Icons.notification_important_rounded), label: 'C Screen',),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'D Screen',),
        ],
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int idx) => _onItemTapped(idx, context),
      ),
    );
  }

  /// Builds the app bar leading button using the current location [Uri].
  /// The [Scaffold]'s default back button cannot be used because it doesn't
  /// have the context of the current child.
  Widget? _buildLeadingButton(BuildContext context) {
    final RouteMatchList currentConfiguration = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration;
    final RouteMatch lastMatch = currentConfiguration.last;
    final Uri location = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches.uri
        : currentConfiguration.uri;
    final bool canPop = location.pathSegments.length > 1;
    return canPop ? 
      BackButton(onPressed: GoRouter.of(context).pop) 
      : 
      IconButton(onPressed: () => GoRouter.of(context).goNamed('menu'), icon: Icon(Icons.menu),);
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    int index = 0;
    if (location.startsWith('/a')) {
      index = 0;
    }
    if (location.startsWith('/b')) {
      index = 1;
    }
    if (location.startsWith('/c')) {
      index = 2;
    }
    if (location.startsWith('/d')) {
      index = 3;
    }

    print('calculater index for ' + location + ' is ' + index.toString());
    return index;
  }

  void _onItemTapped(int index, BuildContext context) {
    String goto = '/a';
    switch (index) {
      case 0: goto = '/a';
      case 1: goto = '/b';
      case 2: goto = '/c';
      case 3: goto = '/d';
    }

    print('will be navigating to ' + goto);
    GoRouter.of(context).go(goto);
  }
}

/// The first screen in the bottom navigation bar.
class ScreenA extends StatelessWidget {
  /// Constructs a [ScreenA] widget.
  const ScreenA({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            GoRouter.of(context).go('/a/details');
          },
          child: const Text('View A details'),
        ),
      ),
    );
  }
}

/// The second screen in the bottom navigation bar.
class ScreenB extends StatelessWidget {
  /// Constructs a [ScreenB] widget.
  const ScreenB({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            GoRouter.of(context).go('/b/details');
          },
          child: const Text('View B details'),
        ),
      ),
    );
  }
}

/// The third screen in the bottom navigation bar.
class ScreenC extends StatelessWidget {
  /// Constructs a [ScreenC] widget.
  const ScreenC({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            GoRouter.of(context).go('/c/details');
          },
          child: const Text('View C details'),
        ),
      ),
    );
  }
}


/// The third screen in the bottom navigation bar.
class ScreenD extends StatelessWidget {
  /// Constructs a [ScreenD] widget.
  const ScreenD({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            GoRouter.of(context).go('/d/details');
          },
          child: const Text('View D details'),
        ),
      ),
    );
  }
}

/// The details screen for either the A, B or C screen.
class DetailsScreen extends StatelessWidget {
  /// Constructs a [DetailsScreen].
  const DetailsScreen({required this.label, super.key});

  /// The label to display in the center of the screen.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Details for $label',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

class Menu extends StatelessWidget {
  Menu({super.key});

  final List<String> items = List<String>.generate(8, (i) => 'Item $i');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clickable List Items'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          // Use ListTile for a standard, tappable list item layout
          return ListTile(
            title: Text(item),
            leading: const Icon(Icons.list),
            // The onTap callback makes the item clickable
            onTap: () {
              if(item.startsWith('Item 3')) {
                GoRouter.of(context).go('/b/details');  
              } else {
              // Action to perform when tapped
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('You tapped on $item')),
                );
              }
              // You can also navigate to another screen here:
              // Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(item: item)));
            },
          );
        },
      ),
    );
  }
}

/// The details screen for either the A, B or C screen.
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({required this.label, super.key});

  /// The label to display in the center of the screen.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'This is a snug. We have an error $label',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

class AutoApiCallScreen extends StatefulWidget {
  const AutoApiCallScreen({super.key});

  @override
  _AutoApiCallScreenState createState() => _AutoApiCallScreenState();
}

class _AutoApiCallScreenState extends State<AutoApiCallScreen> {
  late Timer timer;
  String apiResponseStatus = "Waiting for api call";

  @override
  void initState() {
    super.initState();
    // Start the timer to call the API every 1 minute (60 seconds)
    timer = Timer.periodic(
      const Duration(seconds: 15),
      (Timer t) => _callApiPeriodically(),
    );
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    print('timer disposal called here');
    timer.cancel();
    super.dispose();
  }

  Future<void> _callApiPeriodically() async {
    //final url = Uri.parse('https://zenquotes.io/api/random'); 
    try {
      final response = await http.get(Uri.parse('https://zenquotes.io/api/random'));
      if (response.statusCode == 200) {
        setState(() {
          List<Quote> list = parse(response.body);
          apiResponseStatus = list[0].title;
        });
        // Further data processing can be done here (e.g., json decode, update state)
      } else {
        setState(() {
          apiResponseStatus = "Failed: Status ${response.statusCode} at ${DateTime.now().toString()}";
        });
      }
    } catch (e) {
      setState(() {
        apiResponseStatus = "Error: $e at ${DateTime.now().toString()}";
      });
    }
  }

  // A function that converts a response body into a List<Photo>.
  List<Quote> parse(String responseBody) {
    final parsed = (jsonDecode(responseBody) as List<Object?>)
        .cast<Map<String, Object?>>();

    return parsed.map<Quote>(Quote.fromJson).toList();
  }

  Future<List<Quote>> fetch(http.Client client) async {
    final response = await client.get(
      Uri.parse('https://zenquotes.io/api/random') 
    );

    // Synchronously run parsePhotos in the main isolate.
    return parse(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Periodic API Call")),
      body: Center(
        child: Text(apiResponseStatus),
      ),
    );
  }
}

/*
[
  {
    "q": "No one returns from a long journey the same person they were before.",
    "a": "Zen Proverb",
    "h": "\u003Cblockquote\u003E&ldquo;No one returns from a long journey the same person they were before.&rdquo; &mdash; \u003Cfooter\u003EZen Proverb\u003C/footer\u003E\u003C/blockquote\u003E"
  }
]
*/
class Quote {
  final String title;
  final String a;
  final String html;

  const Quote({
    required this.title,
    required this.a,
    required this.html,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      title: json['q'] as String,
      a: json['a'] as String,
      html: json['h'] as String,
    );
  }
}
