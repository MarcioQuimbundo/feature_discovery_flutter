import 'package:feature_discovery/layout.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feature Discovery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: DescribedFeatureOverlay(
          showOverlay: false,
          icon: Icons.menu,
          color: Colors.green,
          title: "The title",
          description: "The description",
          child: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {},
          ),
        ),
        title: Text(""),
        actions: <Widget>[
          DescribedFeatureOverlay(
            showOverlay: false,
            icon: Icons.search,
            color: Colors.green,
            title: "The title",
            description: "The description",
            child: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Content(),
      floatingActionButton: DescribedFeatureOverlay(
        showOverlay: false,
        icon: Icons.add,
        color: Colors.blue,
        title: "The title",
        description: "The description",
        child: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {},
        ),
      ),
    );
  }
}

class Content extends StatefulWidget {
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Image.network(
              "https://www.visitnewportbeach.com/wp-content/uploads/2018/04/star700x400-700x400.jpg",
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200.0,
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              color: Colors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Starbucks Coffe",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  Text(
                    "Coffe Shop",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              child: RaisedButton(
                onPressed: () {},
                child: Text("Do Feature Discovery"),
              ),
            )
          ],
        ),
        Positioned(
          top: 200,
          right: 0,
          child: FractionalTranslation(
            translation: Offset(-0.5, -0.5),
            child: DescribedFeatureOverlay(
              showOverlay: true,
              icon: Icons.drive_eta,
              color: Colors.blue,
              title: "The title",
              description: "The description",
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                child: Icon(Icons.drive_eta),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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
