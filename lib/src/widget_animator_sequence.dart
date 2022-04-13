import 'dart:async';
import 'package:flutter/material.dart';

import '../widget_and_text_animator.dart';

class WidgetAnimatorSequence extends StatefulWidget {
  const WidgetAnimatorSequence({Key? key, required this.children, this.tapToProceed, this.loop, this.transitionTime, this.onPressed}) : super(key: key);

  final List<WidgetAnimator> children;
  final bool? tapToProceed;
  final bool? loop;
  final Duration? transitionTime;
  final Function? onPressed;

  @override
  State<WidgetAnimatorSequence> createState() => _WidgetAnimatorSequenceState();
}

class _WidgetAnimatorSequenceState extends State<WidgetAnimatorSequence> {

  int currentChildToRender = 0;
  late Timer? _timer;

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    WidgetAnimator widgetAnimatorToShow = widget.children[currentChildToRender];

    return GestureDetector(
        onTap: () {
          _timer?.cancel();
          if (widget.tapToProceed??false){
            int nextChild = _getNextChild();
            if (mounted) {
              if (currentChildToRender!=nextChild) {
                setState(() {
                  currentChildToRender = nextChild;
                });
              }
            }
            if (widget.onPressed!=null){
              widget.onPressed;
            }
          }
        },
        child: WidgetAnimator(
          outgoingEffect: widgetAnimatorToShow.outgoingEffect,
          incomingEffect: widgetAnimatorToShow.incomingEffect,
          atRestEffect: widgetAnimatorToShow.atRestEffect,
          child: Container(
            key: ValueKey('widget$currentChildToRender'),
            child: widgetAnimatorToShow.child,),
          onIncomingAnimationComplete: (_){
            if (widgetAnimatorToShow.onIncomingAnimationComplete!=null) {
              widgetAnimatorToShow.onIncomingAnimationComplete;
            }
            if (widget.transitionTime!=null){
              _timer = Timer(widget.transitionTime!, () {
                if (mounted) {
                  int nextChild = _getNextChild();
                  if (currentChildToRender!=nextChild) {
                    setState(() {
                      currentChildToRender = nextChild;
                    });
                  }
                }
              });
            }
          },
          onOutgoingAnimationComplete: widgetAnimatorToShow.onOutgoingAnimationComplete
        ));
  }

  int _getNextChild() {
    int nextChild = currentChildToRender+1;
    if (nextChild>=widget.children.length){
      if ((widget.loop??false)==true) {
        nextChild = 0;
      }
      else{
        nextChild = nextChild - 1;
      }
    }
    return nextChild;
  }
}