
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveRoundButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onReleased;
  const RiveRoundButton({super.key, this.onPressed, this.onReleased});

  @override
  State<RiveRoundButton> createState() => _RiveRoundButtonState();
}

class _RiveRoundButtonState extends State<RiveRoundButton> {

  StateMachineController? _controller;

  @override
  Widget build(BuildContext context) {
    return RiveAnimation.asset(
      "assets/anim_rive/round_button.riv",
      fit: BoxFit.contain,
      onInit: (Artboard art) {
        _controller = StateMachineController.fromArtboard(
          art,
          "State Machine 1",
          onStateChange: (String stateMachine, String state) {

            switch (state) {
              case "Button Pressed":
                if (widget.onPressed != null) {
                  widget.onPressed!();
                }

              case "Button Release":
                if (widget.onReleased != null) {
                  widget.onReleased!();
                }

              default:
                break;
            }
          },
        );
        art.addController(_controller!);
      },
    );
  }
}
