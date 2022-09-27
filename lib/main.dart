import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
      home: const MyHomePage(title: 'Hello Geofence'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> bgEvents = [];
  late bool _enabled;
  late bool _isMoving;

  @override
  void initState() {
    super.initState();

    _enabled = false;
    _isMoving = false;

    /* bg.BackgroundGeolocation.onLocation((bg.Location location) {
      setState(() {
        bgEvents.add(
            "[Location] - latitude = ${location.coords.latitude} / longitude = ${location.coords.longitude}");
        _isMoving = location.isMoving;
      });
    }); */

    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      setState(() {
        String text;
        if (location.isMoving) {
          text =
              '[onMotionChange] Device has just started MOVING latitude = ${location.coords.latitude} / longitude = ${location.coords.longitude}';
        } else {
          text =
              '[onMotionChange] Device has just STOPPED:  latitude = ${location.coords.latitude} / longitude = ${location.coords.longitude}';
        }
        bgEvents.add(text);
      });
    });

    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
      setState(() {
        bgEvents.add("[providerChange] - $event");
      });
    });

    bg.BackgroundGeolocation.addGeofence(
      bg.Geofence(
        identifier: "Yper",
        radius: 200,
        latitude: 50.69774627685547,
        longitude: 3.169513463973999,
        notifyOnDwell: true,
        notifyOnEntry: true,
        notifyOnExit: true,
      ),
    );

    bg.BackgroundGeolocation.addGeofence(
      bg.Geofence(
        identifier: "Home",
        radius: 50,
        latitude: 50.725826263427734,
        longitude: 3.159290075302124,
        notifyOnDwell: true,
        notifyOnEntry: true,
        notifyOnExit: true,
      ),
    );

    bg.BackgroundGeolocation.addGeofence(
      bg.Geofence(
        identifier: "125 Rue de Tourcoing",
        radius: 50,
        latitude: 50.70280838012695,
        longitude: 3.172015905380249,
        notifyOnDwell: true,
        notifyOnEntry: true,
        notifyOnExit: true,
      ),
    );

    bg.BackgroundGeolocation.addGeofence(
      bg.Geofence(
        identifier: "202 Rue de Roubaix",
        radius: 50,
        latitude: 50.713111877441406,
        longitude: 3.165316581726074,
        notifyOnDwell: true,
        notifyOnEntry: true,
        notifyOnExit: true,
      ),
    );

    bg.BackgroundGeolocation.addGeofence(
      bg.Geofence(
        identifier: "Friesday",
        radius: 50,
        latitude: 50.713111877441406,
        longitude: 3.165316581726074,
        notifyOnDwell: true,
        notifyOnEntry: true,
        notifyOnExit: true,
      ),
    );

    bg.BackgroundGeolocation.onGeofence((bg.GeofenceEvent geofenceEvent) {
      try {
        var identifier = geofenceEvent.identifier;
        var action = geofenceEvent.action;

        setState(() {
          bgEvents.add("[onGeofence] - $action $identifier");
        });
      } catch (e) {
        setState(() {
          bgEvents.add("[onGeofence] - error = $e");
        });
      }
    });

    bg.BackgroundGeolocation.changePace(true);

    bg.BackgroundGeolocation.ready(
      bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        logLevel: bg.Config.LOG_LEVEL_VERBOSE,
        locationAuthorizationRequest: 'WhenInUse',
        notification: bg.Notification(
          title: "Suivi de votre livraison en cours",
          text:
              "Yper utilise votre géolocalisation afin de vous guider au mieux dans vos livraisons. Gérez les permissions de l’application dans les paramètres de localisation de votre téléphone.",
          priority: bg.Config.NOTIFICATION_PRIORITY_MIN,
        ),
      ),
    ).then((bg.State state) {
      setState(() {
        bgEvents.add("[ready state] - $state");
      });
    });
  }

  void _onClickEnabled(bool enabled) async {
    callback(bg.State state) async {
      setState(() {
        bgEvents.add('[_onClickEnabled] success: $state');
        _enabled = state.enabled;
        _isMoving = state.isMoving ?? false;
      });
    }

    if (enabled) {
      bg.BackgroundGeolocation.start().then(callback);
    } else {
      bg.BackgroundGeolocation.stop().then(callback);
    }
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
        actions: [Switch(value: _enabled, onChanged: _onClickEnabled)],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            bgEvents = [];
          });
        },
        child: const Icon(Icons.delete_forever),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              color: _isMoving ? Colors.green : Colors.red,
              child: Text(_isMoving ? "En mouvement" : "A l'arrêt"),
            ),
            Expanded(
              child: ListView(
                reverse: true,
                shrinkWrap: true,
                children: bgEvents.map((e) => _listItem(e)).toList(),
              ),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _listItem(String text) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(text),
          ),
          const Divider(),
        ],
      );
}
