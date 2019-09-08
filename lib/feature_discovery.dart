/*  - - - - - - - - - - - - - -   */
import 'package:feature_discovery/layout.dart';
import 'package:flutter/material.dart';

class FeatureDiscovery extends StatefulWidget {
  static String activeStep(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedFeatureDiscovery)
            as _InheritedFeatureDiscovery)
        .activeStepId;
  }

  static void discoverFeatures(BuildContext context, List<String> steps) {
    _FeatureDiscoveryState state =
        context.ancestorStateOfType(TypeMatcher<_FeatureDiscoveryState>())
            as _FeatureDiscoveryState;

    state.discoverFeatures(steps);
  }

  static void markStepComplete(BuildContext context, String stepId) {
    _FeatureDiscoveryState state =
        context.ancestorStateOfType(TypeMatcher<_FeatureDiscoveryState>())
            as _FeatureDiscoveryState;

    state.markStepComplete(stepId);
  }

  static void dismiss(BuildContext context) {
    _FeatureDiscoveryState state =
        context.ancestorStateOfType(TypeMatcher<_FeatureDiscoveryState>())
            as _FeatureDiscoveryState;

    state.dismiss();
  }

  final Widget child;
  FeatureDiscovery({this.child});

  _FeatureDiscoveryState createState() => _FeatureDiscoveryState();
}

class _FeatureDiscoveryState extends State<FeatureDiscovery> {
  List<String> steps;
  int activeStepIndex;

  void discoverFeatures(List<String> steps) {
    setState(() {
      this.steps = steps;
      activeStepIndex = 0;
    });
  }

  void markStepComplete(String stepId) {
    if (steps != null && steps[activeStepIndex] == stepId) {
      setState(() {
        ++activeStepIndex;
        if (activeStepIndex >= steps.length) {
          _cleanupAfterSteps();
        }
      });
    }
  }

  void dismiss() {
    setState(() {
      _cleanupAfterSteps();
    });
  }

  void _cleanupAfterSteps() {
    steps = null;
    activeStepIndex = null;
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedFeatureDiscovery(
      activeStepId: steps?.elementAt(activeStepIndex),
      child: widget.child,
    );
  }
}

class _InheritedFeatureDiscovery extends InheritedWidget {
  final String activeStepId;

  _InheritedFeatureDiscovery({this.activeStepId, child}) : super(child: child);

  @override
  bool updateShouldNotify(_InheritedFeatureDiscovery oldWidget) {
    return oldWidget.activeStepId != activeStepId;
  }
}

class DescribedFeatureOverlay extends StatefulWidget {
  final String featureId;
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final Widget child;
  DescribedFeatureOverlay(
      {this.featureId,
      this.icon,
      this.color,
      this.title,
      this.description,
      this.child});

  _DescribedFeatureOverlayState createState() =>
      _DescribedFeatureOverlayState();
}

class _DescribedFeatureOverlayState extends State<DescribedFeatureOverlay> {
  Size screenSize;
  bool showOverlay = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;

    showOverlayIfActiveStep();
  }

  void showOverlayIfActiveStep() {
    String activeStep = FeatureDiscovery.activeStep(context);
    setState(() => showOverlay = activeStep == widget.featureId);
  }

  void activate() {
    FeatureDiscovery.markStepComplete(context, widget.featureId);
  }

  void dismiss() {
    FeatureDiscovery.dismiss(context);
  }

  Widget buildOverlay(Offset anchor) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: dismiss,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
          ),
        ),
        new _Background(
            state: _OverlayState.opening,
            transitionPercent: 1.0,
            anchor: anchor,
            color: widget.color,
            screenSize: screenSize),
        new _Content(
          state: _OverlayState.opening,
          transitionPercent: 1.0,
          anchor: anchor,
          screenSize: screenSize,
          title: widget.title,
          description: widget.description,
          touchTargetRadius: 44.0,
          touchTargetToContentPadding: 20.0,
        ),
        new _TouchTarget(
            state: _OverlayState.opening,
            transitionPercent: 1.0,
            anchor: anchor,
            icon: widget.icon,
            color: widget.color,
            onPressed: activate)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnchoredOverlay(
      showOverlay: showOverlay,
      overlayBuilder: (BuildContext context, Offset anchor) {
        return buildOverlay(anchor);
      },
      child: widget.child,
    );
  }
}

class _Background extends StatelessWidget {
  final _OverlayState state;
  final double transitionPercent;
  final Offset anchor;
  final Color color;
  final Size screenSize;

  _Background(
      {this.state,
      this.transitionPercent,
      this.anchor,
      this.color,
      this.screenSize});

  bool isCloseToTopOrBottom(Offset position) {
    return position.dy <= 88.0 || (screenSize.height - position.dy) <= 88.0;
  }

  bool isOnTopHalfOfScreen(Offset position) {
    return position.dy < (screenSize.height / 2.0);
  }

  bool isOnLeftHalfOfScreen(Offset position) {
    return position.dx < (screenSize.width / 2.0);
  }

  @override
  Widget build(BuildContext context) {
    final isBackgroundCentered = isCloseToTopOrBottom(anchor);
    final backgroundRadius =
        screenSize.width * (isBackgroundCentered ? 1.0 : 0.75);

    final backgroundPosition = isBackgroundCentered
        ? anchor
        : Offset(
            screenSize.width / 2.0 +
                (isOnLeftHalfOfScreen(anchor) ? -20.0 : 20.0),
            anchor.dy +
                (isOnTopHalfOfScreen(anchor)
                    ? -(screenSize.width / 2.0) + 40.0
                    : (screenSize.width / 2.0) - 40.0));
    return CenterAbout(
      position: backgroundPosition,
      child: Container(
        width: 2 * backgroundRadius,
        height: 2 * backgroundRadius,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: color.withOpacity(0.96)),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final _OverlayState state;
  final double transitionPercent;
  final Offset anchor;
  final Size screenSize;
  final String title;
  final String description;
  final double touchTargetRadius;
  final double touchTargetToContentPadding;

  _Content(
      {this.state,
      this.transitionPercent,
      this.anchor,
      this.screenSize,
      this.title,
      this.description,
      this.touchTargetRadius,
      this.touchTargetToContentPadding});

  bool isCloseToTopOrBottom(Offset position) {
    return position.dy <= 88.0 || (screenSize.height - position.dy) <= 88.0;
  }

  bool isOnTopHalfOfScreen(Offset position) {
    return position.dy < (screenSize.height / 2.0);
  }

  DescribedFeatureContentOrientation getContentOrientation(Offset position) {
    if (isCloseToTopOrBottom(position)) {
      if (isOnTopHalfOfScreen(position)) {
        return DescribedFeatureContentOrientation.below;
      } else {
        return DescribedFeatureContentOrientation.above;
      }
    } else {
      if (isOnTopHalfOfScreen(position)) {
        return DescribedFeatureContentOrientation.above;
      } else {
        return DescribedFeatureContentOrientation.below;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentOrientation = getContentOrientation(anchor);
    final contentOffsetMultiplier =
        contentOrientation == DescribedFeatureContentOrientation.below
            ? 1.0
            : -1.0;
    final contentY =
        anchor.dy + (contentOffsetMultiplier * (touchTargetRadius + 20.0));
    final contentFactionOffset = contentOffsetMultiplier.clamp(-1.0, 0.0);

    return Positioned(
      top: contentY,
      child: FractionalTranslation(
        translation: Offset(0.0, contentFactionOffset),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.only(left: 40.0, right: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                Text(description,
                    style: TextStyle(
                        fontSize: 18, color: Colors.white.withOpacity(0.9)))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TouchTarget extends StatelessWidget {
  final _OverlayState state;
  final double transitionPercent;
  final Offset anchor;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  _TouchTarget(
      {this.state,
      this.transitionPercent,
      this.anchor,
      this.icon,
      this.color,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    final touchTargetRadius = 44.0;
    return CenterAbout(
      position: anchor,
      child: Container(
        width: 2 * touchTargetRadius,
        height: 2 * touchTargetRadius,
        child: RawMaterialButton(
          shape: CircleBorder(),
          onPressed: onPressed,
          fillColor: Colors.white,
          child: Icon(
            icon,
            color: color,
          ),
        ),
      ),
    );
  }
}

enum DescribedFeatureContentOrientation { above, below }

enum _OverlayState { close, opening, pulsing, activating, dismissing }
