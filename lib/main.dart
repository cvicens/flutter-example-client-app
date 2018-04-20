import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fh_sdk/fh_sdk.dart';

void main() => runApp(new MyApp());

class TitleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.fromLTRB(32.0, 24.0, 32.0, 24.0),
      child: new Row(
        children: [
          new Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                new Text(
                  'This is just and example Flutter app using the hello endpoint. Please, type something (your name for instance) and hit the button',
                  style: new TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BuildContext _context;

  bool _sdkInit = false;

  @override
  initState() {
    super.initState();
    initSDK(); // Init Red Hat Mobile SDK
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initSDK() async {
    String result;
    String message = 'Init call running';

    try {
      result = await FhSdk.init();
      print('init call ' + result);
      message = result.toString();
      showSnackBarMessage(message);

      getCloudUrl();
    } on PlatformException catch (e) {
      message = 'Error in FH Init $e';
      print(message);
      showSnackBarMessage(message);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _sdkInit = result != null && result.contains('SUCCESS') ? true : false;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  getCloudUrl() async {
    String result;
    String message;

    try {
      result = await FhSdk.getCloudUrl();
      print('cloudHost' + result);
      message = result.toString();
      showSnackBarMessage(message);
    } on PlatformException catch (e) {
      message = 'Error in FH getCloudUrl $e';
      showSnackBarMessage(message);
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  sayHello(String name) async {
    dynamic data;
    String message;

    String hello = (name == null || name.length <= 0) ? 'world' : name;

    try {
      Map options = {
        "path": "/hello?hello=" + hello.replaceAll(' ', ''),
        "method": "GET",
        "contentType": "application/json",
        "timeout":
            25000 // timeout value specified in milliseconds. Default: 60000 (60s)
      };
      data = await FhSdk.cloud(options);
      print('data ==> ' + data.toString());
      message = data.toString();
      showSnackBarMessage(message);
    } on PlatformException catch (e, s) {
      print('Exception details:\n $e');
      print('Stack trace:\n $s');
      message = 'Error calling hello/';
      showSnackBarMessage(message);
    }
  }

  void showSnackBarMessage(String message, [int duration = 3]) {
    Scaffold.of(_context).showSnackBar(new SnackBar(
      content: new Text(message),
      duration: new Duration(seconds: duration),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _nameFieldController = new TextEditingController();
    TitleSection titleSection = new TitleSection();
    Container formSection = new Container(
      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 16.0),
      child: new Row(
        children: [
          new Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                new ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: new TextField(
                    controller: _nameFieldController,
                    decoration: new InputDecoration(
                      hintText: "Name",
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );

    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: new Text('Red Hat MAP - Hello Test'),
          ),
          body: new Builder(
            // Create an inner BuildContext so that the onPressed methods
            // can refer to the Scaffold with Scaffold.of().
            builder: (BuildContext context) {
              _context = context;
              return new ListView(children: [
              titleSection,
              formSection,
              const Divider(
                height: 1.0,
              ),
              new Container(
                  padding: const EdgeInsets.fromLTRB(32.0, 28.0, 32.0, 8.0),
                  child: new RaisedButton(
                      child: new Text(_sdkInit ? 'Say Hello to Username' : 'Init in progress...'),
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      onPressed: !_sdkInit ? null : () {
                              // Perform some action
                              sayHello(_nameFieldController.text);
                      }
                  )
              )
            ]);
          })),
    );
  }
}
