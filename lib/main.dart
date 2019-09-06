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
    return OverlayBuilder(
      showOverlay: true,
      overlayBuilder: (BuildContext context) {
        return CenterAbout(
          position: Offset(200.0, 500.0),
          child: Container(
            width: 50.0,
            height: 50.0,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.purple),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {},
          ),
          title: Text(""),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {},
            ),
          ],
        ),
        body: Content(),
        floatingActionButton: FloatingActionButton(
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
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              child: Icon(Icons.drive_eta),
            ),
          ),
        ),
      ],
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
