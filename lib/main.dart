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
  // Change this to match your Authentication Policy on Red Hat Mobile if you plan to test authentication
  static const String AUTH_POLICY = 'flutter';

  BuildContext _context;

  bool _sdkInit = false;

  @override
  initState() {
    super.initState();
    initPlugin(); // Init plugin lowlevel
    initSDK(); // Init Red Hat Mobile SDK
  }

  // This method takes care of push notifications
  void notificationHandler (MethodCall call) {
    assert(call != null);
    if ('push_message_received' == call.method) {
        print ('push_message_received ' + call.toString());
        if (call.arguments != null && call.arguments['userInfo'] != null) {
          var userInfo = call.arguments['userInfo'];
          showSnackBarMessage(userInfo['aps']['alert']['body']);
        } else {
          showSnackBarMessage(call.toString());
        }
      }
  }

  // Initialize plugin this allows us to receive push notification messages
  initPlugin() async {
    String message = 'Init plugin in progress...';

    try {
      FhSdk.initialize(notificationHandler);
      print('plugin channel ready');
      message = 'Plugin channel ready';
      showSnackBarMessage(message);
    } on PlatformException catch (e) {
      message = 'Error in plugin initialize method $e';
      showSnackBarMessage(message);
    }
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
    } on PlatformException catch (e) {
      message = 'Error in FH Init $e';
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

  // Authentication test
  auth(String authPolicy, String username, String password) async {
    dynamic data;
    String message;

    try {
      data = await FhSdk.auth(authPolicy, username, password);
      message = 'Authentication success';
      showSnackBarMessage (message);
      print('auth data' + data.toString());
    } catch (e, s) {
      print('Exception details:\n $e');
      print('Stack trace:\n $s');
      message = 'Authentication error';
      showSnackBarMessage (message);
    }
  }

  // Registers for RH Mobile Push Notifications with alias and categories
  // Both parameters, alias and categories cannot be null (categories can be empty though)
  pushRegister(String alias, List<String> categories) async {
    dynamic data;
    String message;

    try {
      data = await FhSdk.pushRegisterWithAliasAndCategories(alias, categories);
      message = data.toString();
      showSnackBarMessage('Registered as: ' + alias + ' as ' + categories.toString());
      print('pushRegister data ' + data.toString());
    } on PlatformException catch (e, s) {
      print('Exception details:\n $e');
      print('Stack trace:\n $s');
      message = 'Error calling pushRegister';
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
    final TextEditingController _usernameFieldController = new TextEditingController();
    final TextEditingController _passwordFieldController = new TextEditingController();
    final TextEditingController _categoryFieldController = new TextEditingController();
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
                ),
                new ListTile(
                  leading: const Icon(Icons.person),
                  title: new TextField(
                    controller: _usernameFieldController,
                    autocorrect: false,
                    decoration: new InputDecoration(
                      hintText: "Username",
                    ),
                  ),
                ),
                new ListTile(
                  leading: const Icon(Icons.vpn_key),
                  title: new TextField(
                    controller: _passwordFieldController,
                    obscureText: true,
                    autocorrect: false,
                    decoration: new InputDecoration(
                      hintText: "Password",
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
          //floatingActionButton: new FloatingActionButton(
          //  tooltip: 'Add', // used by assistive technologies
          //  child: new Icon(Icons.add),
          //  onPressed: null,
          //),
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
              ),
              new Container(
                  padding: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
                  child: new RaisedButton(
                      child: new Text(_sdkInit ? 'Test auth' : 'Init in progress...'),
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      onPressed: !_sdkInit ? null : () {
                              auth(AUTH_POLICY, _usernameFieldController.text,  _passwordFieldController.text);
                              getCloudUrl();
                      }
                  )
              )
            ]);
          })),
    );
  }
}
