import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:rive/src/rive_core/state_machine_controller.dart' as core;

class RiveAnimationWidget extends StatefulWidget {
  final String? assetUrl;
  final String? stateMachineName;
  final Map<String, double>? inputKeyValues;
  final double lerpWeight;

  const RiveAnimationWidget({super.key, this.assetUrl, this.stateMachineName, this.inputKeyValues, this.lerpWeight = 1.0});

  @override
  State<RiveAnimationWidget> createState() => _RiveAnimationWidgetState();
}

class _RiveAnimationWidgetState extends State<RiveAnimationWidget> {

  StateMachineController? _controller;
  Map<String, int?> _keyIdMap = {};
  Map<String, double> _currentInputKeyValues = {};
  Map<int, double?> _outputKeyValues = {};

  Map<String, String> _stateMap = {};

  void _onInit(Artboard art) {
    if (widget.stateMachineName != null) {
      var ctrl = CustomStateMachineController.fromArtboard(
        art,
        widget.stateMachineName!,
        onInputChanged: (int id, value) {
          setState(() {
            _outputKeyValues[id] = value;
            _outputKeyValues = _outputKeyValues;
          });
        },
        onStateChange: (String stateMachineName, String stateName) {
          setState(() {
            _stateMap[stateMachineName] = stateName;
            _stateMap = _stateMap;
          });
        },
      ) as StateMachineController;

      art.addController(ctrl);

      setState(() {
        _controller = ctrl;
      });

      setState(() {
        for (SMIInput input in ctrl.inputs) {
          _keyIdMap[input.name] = input.id;
          _keyIdMap = _keyIdMap;
        }
      });

      _refreshInputState();
    }
  }


  late Timer _timer;

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(milliseconds: 32), (timer) {
      _refreshInputState();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }



  void _refreshInputState() {
    if (widget.inputKeyValues != null) {
      for (var key in widget.inputKeyValues!.keys) {
        _currentInputKeyValues[key] = (_currentInputKeyValues[key] == null
            ? widget.inputKeyValues![key]
            : lerpDouble(_currentInputKeyValues[key], widget.inputKeyValues![key], widget.lerpWeight))!;
      }
    }

    for (var key in _currentInputKeyValues.keys) {
      var inputId = _keyIdMap.containsKey(key) ? _keyIdMap[key] : null;
      if (inputId != null) {
        _controller?.setInputValue(inputId, _currentInputKeyValues[key]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.assetUrl != null) {
      return RiveAnimation.asset(
        widget.assetUrl!,
        onInit: _onInit,
      );
    }
    return Container();
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
    // print('Changed id: $id,  value: $value');
    for (final input in stateMachine.inputs) {
      if (input.id == id) {
        // Do something with the input
        // print('Found input: $input');
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