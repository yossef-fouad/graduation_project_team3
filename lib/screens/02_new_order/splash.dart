import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:order_pad/screens/02_new_order/main_navigation.dart';


class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState() {
    Future.delayed(Duration(seconds: 1) , () {
      Navigator.push(context, MaterialPageRoute(builder: (c) => MainNavigation()));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SvgPicture.asset("assets/logo/logo.svg"),
      ),
    );
  }
}
