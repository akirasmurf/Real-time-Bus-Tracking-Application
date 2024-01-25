import 'package:buslog/bottombar.dart';
import 'package:buslog/createAcct.dart';
import 'package:buslog/disabled.dart';
import 'package:buslog/forgotpassword.dart';
import 'package:buslog/signIn.dart';
import 'package:buslog/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as FBauth;
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as UIAuth;
import 'package:geolocator/geolocator.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    var providers = [UIAuth.EmailAuthProvider()];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.red,
        useMaterial3: false,
        primarySwatch: Colors.red,
        //   textButtonTheme:
        //       TextButtonThemeData(style: ButtonStyle(backgroundColor: MyColor())),
        //   floatingActionButtonTheme: FloatingActionButtonThemeData(
        //       backgroundColor: Colors.red, foregroundColor: Colors.white),
      ),
      initialRoute: FBauth.FirebaseAuth.instance.currentUser == null
          ? '/sign-in'
          : '/home',
      routes: {
        '/sign-in': (context) {
          return SignInScreen();
          // return UIAuth.SignInScreen(
          //   providers: providers,
          //   headerBuilder: (context, constraints, shrinkOffset) {
          //     return Padding(
          //       padding: EdgeInsets.all(20),
          //       child: CircleAvatar(
          //         radius: 64,
          //         child: ClipOval(
          //             // borderRadius: BorderRadius.circular(100),
          //             child: Image.asset(
          //           "assets/logo.png",
          //           fit: BoxFit.fitHeight,
          //         )),
          //       ),
          //     );
          //   },
          //   actions: [
          //     UIAuth.AuthStateChangeAction<UIAuth.SignedIn>((context, state) {
          //       Navigator.pushReplacementNamed(context, '/home');
          //     }),
          //     UIAuth.AuthStateChangeAction<UIAuth.SigningUp>((context, state) {
          //       Navigator.pushReplacementNamed(context, '/signup');
          //     }),
          //   ],
          // );
        },
        '/home': (context) {
          return BottomBar();
        },
        '/createacct': (context) {
          return CreateAccount();
        },
        '/signup': (context) {
          return SignUp();
        },
        '/disabled': (context) {
          return DisabledAccount();
        },
        '/forgot': (context) {
          return ForgotPassword();
        },
      },
    );
  }
}

class MyColor extends MaterialStateColor {
  const MyColor() : super(_defaultColor);

  static const int _defaultColor = 0xcafefeed;
  static const int _pressedColor = 0xdeadbeef;

  @override
  Color resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.pressed)) {
      return const Color(_pressedColor);
    }
    return const Color(_defaultColor);
  }
}
