import 'package:flutter/material.dart';

class AnchoredOverlay extends StatelessWidget {
  final bool showOverlay;
  final Widget Function(BuildContext, Offset anchor) overlayBuilder;
  final Widget child;
  AnchoredOverlay({this.showOverlay, this.overlayBuilder, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return OverlayBuilder(
            showOverlay: showOverlay,
            overlayBuilder: (BuildContext overlayContext) {
              RenderBox box = context.findRenderObject() as RenderBox;
              final center =
                  box.size.center(box.localToGlobal(Offset(0.0, 0.0)));
              return overlayBuilder(overlayContext, center);
            },
            child: child,
          );
        },
      ),
    );
  }
}

class OverlayBuilder extends StatefulWidget {
  final bool showOverlay;
  final Function(BuildContext) overlayBuilder;
  final Widget child;
  OverlayBuilder({this.showOverlay = false, this.overlayBuilder, this.child});

  _OverlayBuilderState createState() => _OverlayBuilderState();
}

class _OverlayBuilderState extends State<OverlayBuilder> {
  OverlayEntry overlayEntry;

  @override
  void initState() {
    super.initState();

    if (widget.showOverlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) => showOverlay());
    }
  }

  @override
  void didUpdateWidget(OverlayBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => syncWidgetAndOverlay());
  }

  @override
  void reassemble() {
    super.reassemble();
    WidgetsBinding.instance.addPostFrameCallback((_) => syncWidgetAndOverlay());
  }

  @override
  void dispose() {
    if (isShowingOverlay()) {
      hideOverlay();
    }
    super.dispose();
  }

  bool isShowingOverlay() => overlayEntry != null;

  void showOverlay() {
    overlayEntry = new OverlayEntry(
      builder: widget.overlayBuilder,
    );
    addToOverlay(overlayEntry);
  }

  void addToOverlay(OverlayEntry entry) async {
    print('addToOverlay');
    Overlay.of(context).insert(entry);
  }

  void hideOverlay() {
    print('hideOverlay');
    overlayEntry.remove();
    overlayEntry = null;
  }

  void syncWidgetAndOverlay() {
    if (isShowingOverlay() && !widget.showOverlay) {
      hideOverlay();
    } else if (!isShowingOverlay() && widget.showOverlay) {
      showOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.child,
    );
  }
}

class CenterAbout extends StatelessWidget {
  final Offset position;
  final Widget child;

  CenterAbout({
    this.position,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return new Positioned(
      top: position.dy,
      left: position.dx,
      child: new FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: child,
      ),
    );
  }
}

/*  - - - - - - - - - - - - - -   */
class DescribedFeatureOverlay extends StatefulWidget {
  final bool showOverlay;
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final Widget child;
  DescribedFeatureOverlay(
      {this.showOverlay,
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
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }

  bool isCloseToTopOrBottom(Offset position) {
    return position.dy <= 88.0 || (screenSize.height - position.dy) <= 88.0;
  }

  bool isOnTopHalfOfScreen(Offset position) {
    return position.dy < (screenSize.height / 2.0);
  }

  bool isOnLeftHalfOfScreen(Offset position) {
    return position.dx < (screenSize.width / 2.0);
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
    return AnchoredOverlay(
      showOverlay: widget.showOverlay,
      overlayBuilder: (BuildContext context, Offset anchor) {
        final touchTargetRadius = 44.0;
        final contentOrientation = getContentOrientation(anchor);
        final contentOffsetMultiplier =
            contentOrientation == DescribedFeatureContentOrientation.below
                ? 1.0
                : -1.0;
        final contentY =
            anchor.dy + (contentOffsetMultiplier * (touchTargetRadius + 20.0));
        final contentFactionOffset = contentOffsetMultiplier.clamp(-1.0, 0.0);
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

        return Stack(
          children: <Widget>[
            CenterAbout(
              position: backgroundPosition,
              child: Container(
                width: 2 * backgroundRadius,
                height: 2 * backgroundRadius,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(0.96)),
              ),
            ),
            Positioned(
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
                            widget.title,
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                        Text(widget.description,
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.9)))
                      ],
                    ),
                  ),
                ),
              ),
            ),
            CenterAbout(
              position: anchor,
              child: Container(
                width: 2 * touchTargetRadius,
                height: 2 * touchTargetRadius,
                child: RawMaterialButton(
                  shape: CircleBorder(),
                  onPressed: () {},
                  fillColor: Colors.white,
                  child: Icon(
                    widget.icon,
                    color: widget.color,
                  ),
                ),
              ),
            )
          ],
        );
      },
      child: widget.child,
    );
  }
}

enum DescribedFeatureContentOrientation { above, below }
