import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:firebase/remote_config_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late RemoteConfigService remoteService;

  @override
  void initState() {
    super.initState();
    remoteService = RemoteConfigService();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
          future: remoteService.setRemoteConfig(),
          builder: (context, AsyncSnapshot<FirebaseRemoteConfig> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: CircularProgressIndicator(color: Colors.red),
              );
            }
            if (snapshot.hasData) {
              return HomePage(snapshot.requireData, remoteService);
            }
            return ErrorPage(remoteService.fetchingErrorStream);
          }),
    );
  }
}

class ErrorPage extends StatelessWidget {
  final Stream<dynamic> error;

  ErrorPage(this.error);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Error: ${error.last}')));
  }
}

class HomePage extends StatelessWidget {
  final FirebaseRemoteConfig remoteConfigData;
  final RemoteConfigService remoteService;

  HomePage(this.remoteConfigData, this.remoteService);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Firebase Remote config demo')),
      ),
      body: const Center(
        child: Text(
          'The button will show depends on remote config',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      floatingActionButton: remoteConfigData.getBool("showModal")
          ? FloatingActionButton(
              onPressed: () async {
                await remoteService.onForceFetched(remoteConfigData);
              },
              child: const Icon(Icons.people, size: 50),
            )
          : null,
    );
  }
}
