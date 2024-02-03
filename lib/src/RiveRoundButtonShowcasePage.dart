
import 'package:demo_flutter_rive/src/RiveRoundButton.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveRoundButtonShowcasePage extends StatefulWidget {
  const RiveRoundButtonShowcasePage({super.key});

  @override
  State<RiveRoundButtonShowcasePage> createState() => _RiveRoundButtonShowcasePageState();
}

class _RiveRoundButtonShowcasePageState extends State<RiveRoundButtonShowcasePage> {

  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text("Round button Showcase"),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              width: 250,
              height: 250,
              child: RiveRoundButton(
                onPressed: () {
                  setState(() {
                    isPressed = true;
                  });
                },
                onReleased: () {
                  setState(() {
                    isPressed = false;
                  });
                },
              )
            ),

            Text(isPressed ? "Pressed!" : "Idle"),
          ],
        ),
      )
    );
  }
}

