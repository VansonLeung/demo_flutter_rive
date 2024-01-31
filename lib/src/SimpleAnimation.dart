

import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:demo_flutter_rive/src/RiveAnimationWidget.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:rive/src/rive_core/state_machine_controller.dart' as core;

class SimpleAnimation extends StatefulWidget {
  const SimpleAnimation({super.key});

  @override
  State<SimpleAnimation> createState() => _SimpleAnimationState();
}

class _SimpleAnimationState extends State<SimpleAnimation> {

  StateMachineController? _controller;

  int? inputId;
  String input = "";
  String state = "";

  void _onInit(Artboard art) {
    var ctrl = CustomStateMachineController.fromArtboard(
      art,
      'State Machine 1',
      onInputChanged: (int id, value) {
        setState(() {
          input = "${id}=${value}";
        });

        if (value == 5.0) {
          _controllerCenter.play();
        } else {
          _controllerCenter.stop();
        }

      },
      onStateChange: (String stateMachineName, String stateName) {
        setState(() {
          state = stateName;
        });
      },
    ) as StateMachineController;
    art.addController(ctrl);
    setState(() {
      _controller = ctrl;
    });

    setState(() {
      for (SMIInput input in ctrl.inputs) {
        if (input.name == "rating") {
          inputId = input.id;
        }
      }
    });


    // ctrl.inputs
    // ctrl.isActive = false;
    // art.addController(ctrl);
    // setState(() {
    //   _controller = ctrl;
    // });
  }


  late ConfettiController _controllerCenter;

  @override
  void initState() {
    super.initState();
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 30));
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    super.dispose();
  }



  /// A custom Path to paint stars.
  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }






  @override
  Widget build(BuildContext context) {

    double star = 0;
    if (inputId != null) {
      star = _controller?.getInputValue(inputId!) ?? 0.0;
    }

    Map<String, double> moodInputValues = {
      "mood_happy_val": max(0, (star - 3) * 50),
      "mood_normal_val": max(0, 100 - ((star - 4) * 50) - ((4 - star) * 50) ),
      "mood_sad_val": max(0, (3 - star) * 50),
    };
    print(moodInputValues);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: RiveAnimation.asset(
              "assets/anim_rive/rating_animation.riv",
              onInit: _onInit,
            ),
          ),

          // Expanded(child: Text("A: ${_controller?.inputs.first.value ?? ""} , B: ${input},  C: ${state}")),
          //
          // Expanded(
          //     child: Row(
          //       children: [
          //
          //         for (int i = 1; i <= 5; i += 1)
          //           ElevatedButton(
          //               onPressed: () {
          //                 if (inputId != null) {
          //                   _controller?.setInputValue(inputId!, (i).toDouble() );
          //                 }
          //               },
          //               child: Text("${i}"),
          //           )
          //       ],
          //     )
          // ),

          Expanded(
            child: Stack(
              children: [
                RiveAnimationWidget(
                  assetUrl: "assets/anim_rive/moody_cat.riv",
                  stateMachineName: "state",
                  inputKeyValues: moodInputValues,
                  lerpWeight: 1/3,
                ),


                Align(
                  alignment: Alignment.center,
                  child: ConfettiWidget(
                    confettiController: _controllerCenter,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: true, // start again as soon as the animation is finished
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.pink,
                      Colors.orange,
                      Colors.purple
                    ], // manually specify the colors to be used
                    createParticlePath: drawStar, // define a custom shape/path.
                  ),
                ),


              ],
            )
          ),
        ]
      ),
    );
  }
}






typedef InputChanged = void Function(int id, dynamic value);

class CustomStateMachineController extends StateMachineController {
  CustomStateMachineController(
      super.stateMachine, {
        core.OnStateChange? onStateChange,
        required this.onInputChanged,
      });

  final InputChanged onInputChanged;

  @override
  void setInputValue(int id, value) {
    print('Changed id: $id,  value: $value');
    for (final input in stateMachine.inputs) {
      if (input.id == id) {
        // Do something with the input
        print('Found input: $input');
      }
    }
    // Or just pass it back to the calling widget
    onInputChanged.call(id, value);
    super.setInputValue(id, value);
  }

  static CustomStateMachineController? fromArtboard(
      Artboard artboard,
      String stateMachineName, {
        core.OnStateChange? onStateChange,
        required InputChanged onInputChanged,
      }) {
    for (final animation in artboard.animations) {
      if (animation is StateMachine && animation.name == stateMachineName) {
        return CustomStateMachineController(
          animation,
          onStateChange: onStateChange,
          onInputChanged: onInputChanged,
        );
      }
    }
    return null;
  }
}